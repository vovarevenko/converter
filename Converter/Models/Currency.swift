//
//  Currency.swift
//  Converter
//

import Foundation

struct Currency: Identifiable, Equatable, Decodable {
    let code: String
    let title: String
    let symbol: String
    let decimals: Int

    var id: String { code }

    func formatValue(_ value: Double) -> String {
        "\(String(format: "%.\(decimals)f", value)) \(symbol)"
    }
}
