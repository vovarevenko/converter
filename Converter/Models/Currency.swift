//
//  Currency.swift
//  Converter
//

import Foundation

struct Currency: Identifiable, Equatable, Codable {
    let code: String
    let title: String
    let symbol: String
    let decimals: Int

    var id: String { code }

    func formatValue(_ value: Double, numberFormat: NumberFormatOption) -> String {
        let resolved = numberFormat.resolved
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.decimalSeparator = resolved.decimalSeparator
        if let grouping = resolved.groupingSeparator {
            formatter.groupingSeparator = grouping
            formatter.usesGroupingSeparator = true
        } else {
            formatter.usesGroupingSeparator = false
        }
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
        return "\(formatted) \(symbol)"
    }
}
