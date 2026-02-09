//
//  Rate.swift
//  Converter
//

import Foundation

struct Rate: Identifiable, Equatable, Codable {
    let currency: Currency
    let rate: Double

    var id: String { currency.id }
}
