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

    private var symbol: String {
        switch code {
        case "USD": "$"
        case "EUR": "€"
        case "RUB": "₽"
        case "BTC": "₿"
        case "ETH": "Ξ"
        case "VND": "₫"
        case "CNY": "¥"
        case "GBP": "£"
        case "UAH": "₴"
        case "KRW": "₩"
        case "JPY": "JP¥"
        case "CAD": "CA$"
        default: code
        }
    }

    func formatValue(_ value: Double) -> String {
        String(format: isCrypto ? "%.6f %@" : "%.2f %@", value, symbol)
    }
}
