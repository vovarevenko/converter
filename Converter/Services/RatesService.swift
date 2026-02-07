//
//  RatesService.swift
//  Converter
//

import Foundation

struct RatesService {
    var baseURL = URL(string: "http://localhost:3000")!

    func fetchRates() async throws -> [Rate] {
        let url = baseURL.appending(path: "rates")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Rate].self, from: data)
    }
}
