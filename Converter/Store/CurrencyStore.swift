//
//  CurrencyStore.swift
//  Converter
//

import SwiftUI

@Observable
class CurrencyStore {
    var allRates: [Rate] = []
    var activeCurrencyCode: String?
    var isLoading = false
    var errorMessage: String?
    var lastRefreshedAt: Date?

    var selectedCurrencyCodes: [String] = [] {
        didSet { if !isLoadingPreferences { saveSelectedCodes() } }
    }

    var rates: [Rate] {
        selectedCurrencyCodes.compactMap { code in
            rate(for: code)
        }
    }

    private var values: [String: Double] = [:]
    private var isLoadingPreferences = false
    private let service = RatesService()

    private enum Keys {
        static let selectedCurrencyCodes = "currency.selectedCodes"
        static let cachedRates = "currency.cachedRates"
        static let cachedAt = "currency.cachedAt"
    }

    private static let defaultCodes = ["USD", "EUR", "GBP", "JPY", "UAH"]
    private static let defaultAmount: Double = 100
    private static let refreshDebounceInterval: TimeInterval = 5 * 60

    init() {
        loadSelectedCodes()
        Task { await refresh() }
    }

    private func loadSelectedCodes() {
        isLoadingPreferences = true
        if let codes = UserDefaults.standard.stringArray(forKey: Keys.selectedCurrencyCodes) {
            selectedCurrencyCodes = codes
        }
        isLoadingPreferences = false
    }

    private func saveSelectedCodes() {
        UserDefaults.standard.set(selectedCurrencyCodes, forKey: Keys.selectedCurrencyCodes)
    }

    private func rate(for code: String) -> Rate? {
        allRates.first { $0.currency.code == code }
    }

    private func recalculateValues(from sourceRate: Rate, amount: Double) {
        let amountInUSD = amount * sourceRate.rate
        for rate in allRates {
            values[rate.currency.code] = amountInUSD / rate.rate
        }
    }

    // MARK: - Cache

    private func saveCache(_ rates: [Rate]) {
        guard let data = try? JSONEncoder().encode(rates) else { return }
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: Keys.cachedRates)
        defaults.set(Date(), forKey: Keys.cachedAt)
    }

    private func loadCache() -> [Rate]? {
        guard let data = UserDefaults.standard.data(forKey: Keys.cachedRates),
              let rates = try? JSONDecoder().decode([Rate].self, from: data) else {
            return nil
        }
        return rates
    }

    private func loadCacheDate() -> Date? {
        UserDefaults.standard.object(forKey: Keys.cachedAt) as? Date
    }

    // MARK: - Refresh

    var needsRefresh: Bool {
        guard let lastRefreshedAt else { return true }
        return Date().timeIntervalSince(lastRefreshedAt) > Self.refreshDebounceInterval
    }

    func refreshIfNeeded() async {
        guard needsRefresh else { return }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchRates()
            allRates = fetched.filter { $0.rate != 0 }
            lastRefreshedAt = Date()
            saveCache(allRates)

            if selectedCurrencyCodes.isEmpty {
                isLoadingPreferences = true
                selectedCurrencyCodes = Self.defaultCodes.filter { code in
                    allRates.contains { $0.currency.code == code }
                }
                isLoadingPreferences = false
                saveSelectedCodes()
            }

            if let activeCode = activeCurrencyCode,
               let activeRate = rate(for: activeCode),
               let currentValue = values[activeCode] {
                recalculateValues(from: activeRate, amount: currentValue)
            } else {
                let initial = rates.first(where: { $0.currency.code == "USD" }) ?? rates.first
                if let initial {
                    activeCurrencyCode = initial.currency.code
                    recalculateValues(from: initial, amount: Self.defaultAmount)
                }
            }
        } catch let urlError as URLError {
            loadCacheIfEmpty()
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                errorMessage = "No internet connection. Please check your network."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            default:
                errorMessage = "Failed to load exchange rates. Please try again later."
            }
        } catch {
            loadCacheIfEmpty()
            errorMessage = "Failed to load exchange rates. Please try again later."
        }

        isLoading = false
    }

    private func loadCacheIfEmpty() {
        guard allRates.isEmpty, let cached = loadCache() else { return }
        allRates = cached
        lastRefreshedAt = loadCacheDate()

        if selectedCurrencyCodes.isEmpty {
            isLoadingPreferences = true
            selectedCurrencyCodes = Self.defaultCodes.filter { code in
                allRates.contains { $0.currency.code == code }
            }
            isLoadingPreferences = false
            saveSelectedCodes()
        }

        let initial = rates.first(where: { $0.currency.code == "USD" }) ?? rates.first
        if let initial {
            activeCurrencyCode = initial.currency.code
            recalculateValues(from: initial, amount: Self.defaultAmount)
        }
    }

    func convert(from currencyCode: String, amount: Double) {
        guard let rate = rate(for: currencyCode) else { return }
        activeCurrencyCode = currencyCode
        recalculateValues(from: rate, amount: amount)
    }

    func getValue(for rate: Rate) -> Double {
        values[rate.currency.code] ?? 0.0
    }

    func toggleCurrency(_ code: String) {
        if selectedCurrencyCodes.contains(code) {
            deleteCurrency(code: code)
        } else {
            selectedCurrencyCodes.append(code)
            if let activeCode = activeCurrencyCode,
               let activeRate = rate(for: activeCode),
               let currentValue = values[activeCode] {
                recalculateValues(from: activeRate, amount: currentValue)
            }
        }
    }

    func isSelected(_ code: String) -> Bool {
        selectedCurrencyCodes.contains(code)
    }

    func deleteCurrency(code: String) {
        selectedCurrencyCodes.removeAll { $0 == code }
        if activeCurrencyCode == code {
            activeCurrencyCode = selectedCurrencyCodes.first
        }
    }

    func moveCurrency(from source: IndexSet, to destination: Int) {
        selectedCurrencyCodes.move(fromOffsets: source, toOffset: destination)
    }
}
