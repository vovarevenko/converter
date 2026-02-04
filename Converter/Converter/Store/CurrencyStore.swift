//
//  CurrencyStore.swift
//  Converter
//

import Foundation
import Observation

@Observable
class CurrencyStore {
    private enum Keys {
        static let activeCurrencyCode = "currency.activeCurrencyCode"
        static let activeValue = "currency.activeValue"
    }

    var currencies: [Currency] = []
    var values: [UUID: Double] = [:]
    var activeCurrencyId: UUID?
    var isLoading: Bool = false

    init() {
        loadDefaultCurrencies()
        loadSavedState()
    }

    private func loadDefaultCurrencies() {
        currencies = [
            Currency(code: "USD", name: "US Dollar", rateToUSD: 1.0),
            Currency(code: "EUR", name: "Euro", rateToUSD: 0.85),
            Currency(code: "RUB", name: "Russian Ruble", rateToUSD: 76.24),
            Currency(code: "BTC", name: "Bitcoin", rateToUSD: 0.000014, isCrypto: true),
            Currency(code: "ETH", name: "Ethereum", rateToUSD: 0.000466, isCrypto: true)
        ]

        // Set USD as active currency with initial value of 100
        if let usd = currencies.first(where: { $0.code == "USD" }) {
            activeCurrencyId = usd.id
            values[usd.id] = 100.0
            recalculateValues(from: usd, amount: 100.0)
        }
    }

    private func loadSavedState() {
        let defaults = UserDefaults.standard

        guard let savedCode = defaults.string(forKey: Keys.activeCurrencyCode),
              let currency = currencies.first(where: { $0.code == savedCode }) else {
            return
        }

        let savedValue = defaults.double(forKey: Keys.activeValue)
        guard savedValue > 0 else { return }

        activeCurrencyId = currency.id
        values[currency.id] = savedValue
        recalculateValues(from: currency, amount: savedValue)
    }

    private func saveState() {
        guard let activeId = activeCurrencyId,
              let activeCurrency = currencies.first(where: { $0.id == activeId }),
              let value = values[activeId] else {
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(activeCurrency.code, forKey: Keys.activeCurrencyCode)
        defaults.set(value, forKey: Keys.activeValue)
    }

    func recalculateValues(from sourceCurrency: Currency, amount: Double) {
        // Convert source amount to USD first
        let amountInUSD = amount / sourceCurrency.rateToUSD

        // Calculate values for all currencies
        for currency in currencies {
            values[currency.id] = amountInUSD * currency.rateToUSD
        }
    }

    func setActive(_ currency: Currency) {
        activeCurrencyId = currency.id
        saveState()
    }

    func getValue(for currency: Currency) -> Double {
        return values[currency.id] ?? 0.0
    }

    func setValue(_ value: Double, for currency: Currency) {
        values[currency.id] = value
        recalculateValues(from: currency, amount: value)
        saveState()
    }

    func refresh() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(2))
        isLoading = false
    }

    func deleteCurrency(_ currency: Currency) {
        currencies.removeAll { $0.id == currency.id }
        values.removeValue(forKey: currency.id)
        if activeCurrencyId == currency.id {
            activeCurrencyId = nil
        }
    }
}
