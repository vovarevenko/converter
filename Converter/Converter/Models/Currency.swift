//
//  Currency.swift
//  Converter
//

import Foundation

struct Currency: Identifiable, Equatable {
    let id: UUID
    let code: String
    let name: String
    let rateToUSD: Double
    let isCrypto: Bool

    init(id: UUID = UUID(), code: String, name: String, rateToUSD: Double, isCrypto: Bool = false) {
        self.id = id
        self.code = code
        self.name = name
        self.rateToUSD = rateToUSD
        self.isCrypto = isCrypto
    }

    var symbol: String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "RUB": return "₽"
        case "BTC": return "₿"
        case "ETH": return "Ξ"
        default: return code
        }
    }

    func formatValue(_ value: Double) -> String {
        if isCrypto {
            return String(format: "%.6f %@", value, symbol)
        } else {
            return String(format: "%.2f %@", value, symbol)
        }
    }
}
