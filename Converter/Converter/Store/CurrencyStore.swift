//
//  CurrencyStore.swift
//  Converter
//

import Foundation
import Observation

@Observable
class CurrencyStore {
    var currencies: [Currency] = []
    var values: [UUID: Double] = [:]
    var activeCurrencyId: UUID?
    var isLoading: Bool = false

    init() {
        loadDefaultCurrencies()
    }

    private func loadDefaultCurrencies() {
        currencies = [
            Currency(code: "USD", name: "US Dollar", rateToUSD: 1.0),
            Currency(code: "EUR", name: "Euro", rateToUSD: 0.85),
            Currency(code: "RUB", name: "Russian Ruble", rateToUSD: 76.24),
            Currency(code: "BTC", name: "Bitcoin", rateToUSD: 0.000014, isCrypto: true),
            Currency(code: "ETH", name: "Ethereum", rateToUSD: 0.000466, isCrypto: true)
        ]

        for currency in currencies {
            values[currency.id] = 0.0
        }
    }

    func setActive(_ currency: Currency) {
        activeCurrencyId = currency.id
    }

    func getValue(for currency: Currency) -> Double {
        return values[currency.id] ?? 0.0
    }

    func setValue(_ value: Double, for currency: Currency) {
        values[currency.id] = value
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
