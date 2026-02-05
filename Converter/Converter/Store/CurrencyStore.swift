//
//  CurrencyStore.swift
//  Converter
//

import SwiftUI

@Observable
class CurrencyStore {
    private enum Keys {
        static let activeCurrencyCode = "currency.activeCurrencyCode"
        static let activeValue = "currency.activeValue"
    }

    var currencies: [Currency] = []
    var activeCurrencyId: UUID?
    private var values: [UUID: Double] = [:]

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
            Currency(code: "ETH", name: "Ethereum", rateToUSD: 0.000466, isCrypto: true),
            Currency(code: "VND", name: "Vietnamese Dong", rateToUSD: 25984.15),
            Currency(code: "CNY", name: "Chinese Yuan", rateToUSD: 6.94),
            Currency(code: "GBP", name: "British Pound", rateToUSD: 0.73),
            Currency(code: "TON", name: "Toncoin", rateToUSD: 0.72, isCrypto: true),
            Currency(code: "UAH", name: "Ukrainian Hryvnia", rateToUSD: 43.12),
            Currency(code: "KRW", name: "South Korean Won", rateToUSD: 1461.26),
            Currency(code: "JPY", name: "Japanese Yen", rateToUSD: 156.86),
            Currency(code: "CAD", name: "Canadian Dollar", rateToUSD: 1.37)
        ]

        if let usd = currencies.first(where: { $0.code == "USD" }) {
            activeCurrencyId = usd.id
            recalculateValues(from: usd, amount: 100.0)
        }
    }

    private func loadSavedState() {
        let defaults = UserDefaults.standard

        guard let savedCode = defaults.string(forKey: Keys.activeCurrencyCode),
              let currency = currencies.first(where: { $0.code == savedCode }),
              defaults.double(forKey: Keys.activeValue) > 0 else {
            return
        }

        let savedValue = defaults.double(forKey: Keys.activeValue)
        activeCurrencyId = currency.id
        recalculateValues(from: currency, amount: savedValue)
    }

    private func saveState() {
        guard let activeId = activeCurrencyId,
              let activeCurrency = currencies.first(where: { $0.id == activeId }),
              let value = values[activeId] else {
            return
        }

        UserDefaults.standard.set(activeCurrency.code, forKey: Keys.activeCurrencyCode)
        UserDefaults.standard.set(value, forKey: Keys.activeValue)
    }

    private func recalculateValues(from sourceCurrency: Currency, amount: Double) {
        let amountInUSD = amount / sourceCurrency.rateToUSD
        for currency in currencies {
            values[currency.id] = amountInUSD * currency.rateToUSD
        }
    }

    func setActive(_ currency: Currency) {
        activeCurrencyId = currency.id
        saveState()
    }

    func getValue(for currency: Currency) -> Double {
        values[currency.id] ?? 0.0
    }

    func refresh() async {
        try? await Task.sleep(for: .seconds(2))
    }

    func deleteCurrency(_ currency: Currency) {
        currencies.removeAll { $0.id == currency.id }
        values.removeValue(forKey: currency.id)
        if activeCurrencyId == currency.id {
            activeCurrencyId = nil
        }
    }

    func moveCurrency(from source: IndexSet, to destination: Int) {
        currencies.move(fromOffsets: source, toOffset: destination)
    }
}
