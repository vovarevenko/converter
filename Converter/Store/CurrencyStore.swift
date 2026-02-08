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

    var selectedCurrencyCodes: [String] = [] {
        didSet { if !isLoadingPreferences { saveSelectedCodes() } }
    }

    var rates: [Rate] {
        selectedCurrencyCodes.compactMap { code in
            allRates.first { $0.currency.code == code }
        }
    }

    private var values: [String: Double] = [:]
    private var isLoadingPreferences = false
    private let service = RatesService()

    private enum Keys {
        static let selectedCurrencyCodes = "currency.selectedCodes"
    }

    private static let defaultCodes = ["USD", "EUR", "GBP", "JPY", "UAH"]

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

    private func recalculateValues(from sourceRate: Rate, amount: Double) {
        let amountInUSD = amount * sourceRate.rate
        for rate in allRates {
            values[rate.currency.code] = amountInUSD / rate.rate
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchRates()
            allRates = fetched.filter { $0.rate != 0 }

            if selectedCurrencyCodes.isEmpty {
                isLoadingPreferences = true
                selectedCurrencyCodes = Self.defaultCodes.filter { code in
                    allRates.contains { $0.currency.code == code }
                }
                isLoadingPreferences = false
                saveSelectedCodes()
            }

            if let activeCode = activeCurrencyCode,
               let activeRate = allRates.first(where: { $0.currency.code == activeCode }),
               let currentValue = values[activeCode] {
                recalculateValues(from: activeRate, amount: currentValue)
            } else {
                let initial = rates.first(where: { $0.currency.code == "USD" }) ?? rates.first
                if let initial {
                    activeCurrencyCode = initial.currency.code
                    recalculateValues(from: initial, amount: 100.0)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func convert(from currencyCode: String, amount: Double) {
        guard let rate = allRates.first(where: { $0.currency.code == currencyCode }) else { return }
        activeCurrencyCode = currencyCode
        recalculateValues(from: rate, amount: amount)
    }

    func getValue(for rate: Rate) -> Double {
        values[rate.currency.code] ?? 0.0
    }

    func toggleCurrency(_ code: String) {
        if let index = selectedCurrencyCodes.firstIndex(of: code) {
            selectedCurrencyCodes.remove(at: index)
            if activeCurrencyCode == code {
                activeCurrencyCode = selectedCurrencyCodes.first
            }
        } else {
            selectedCurrencyCodes.append(code)
            if let rate = allRates.first(where: { $0.currency.code == code }),
               let activeCode = activeCurrencyCode,
               let activeRate = allRates.first(where: { $0.currency.code == activeCode }),
               let currentValue = values[activeCode] {
                let amountInUSD = currentValue * activeRate.rate
                values[code] = amountInUSD / rate.rate
            }
        }
    }

    func isSelected(_ code: String) -> Bool {
        selectedCurrencyCodes.contains(code)
    }

    func deleteCurrency(_ rate: Rate) {
        selectedCurrencyCodes.removeAll { $0 == rate.currency.code }
        if activeCurrencyCode == rate.currency.code {
            activeCurrencyCode = selectedCurrencyCodes.first
        }
    }

    func moveCurrency(from source: IndexSet, to destination: Int) {
        selectedCurrencyCodes.move(fromOffsets: source, toOffset: destination)
    }
}
