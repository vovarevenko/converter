//
//  CurrencyStore.swift
//  Converter
//

import SwiftUI

@Observable
class CurrencyStore {
    var rates: [Rate] = []
    var activeCurrencyCode: String?
    var isLoading = false
    var errorMessage: String?
    private var values: [String: Double] = [:]
    private let service = RatesService()

    init() {
        Task { await refresh() }
    }

    private func recalculateValues(from sourceRate: Rate, amount: Double) {
        let amountInUSD = amount * sourceRate.rate
        for rate in rates {
            values[rate.currency.code] = amountInUSD / rate.rate
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchRates()
            rates = fetched.filter { $0.rate != 0 }

            if let activeCode = activeCurrencyCode,
               let activeRate = rates.first(where: { $0.currency.code == activeCode }),
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

    func setActive(_ rate: Rate) {
        activeCurrencyCode = rate.currency.code
    }

    func getValue(for rate: Rate) -> Double {
        values[rate.currency.code] ?? 0.0
    }

    func deleteCurrency(_ rate: Rate) {
        rates.removeAll { $0.id == rate.id }
        values.removeValue(forKey: rate.currency.code)
        if activeCurrencyCode == rate.currency.code {
            activeCurrencyCode = nil
        }
    }

    func moveCurrency(from source: IndexSet, to destination: Int) {
        rates.move(fromOffsets: source, toOffset: destination)
    }
}
