//
//  Rate.swift
//  Converter
//

import Foundation

struct Rate: Identifiable, Equatable, Decodable {
    let currency: Currency
    let rate: Double

    var id: String { currency.id }
}
