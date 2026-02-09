//
//  RatesService.swift
//  Converter
//

import Foundation

enum RatesError: LocalizedError {
    case invalidResponse(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let code):
            return "Server returned status \(code)"
        }
    }
}

struct RatesService {
    #if DEBUG
    private static let baseURL = URL(string: "http://localhost:3000")!
    #else
    private static let baseURL = URL(string: "https://converter.revenko.org")!
    #endif

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    func fetchRates() async throws -> [Rate] {
        let url = Self.baseURL.appending(path: "rates")
        let (data, response) = try await Self.session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw RatesError.invalidResponse(statusCode: statusCode)
        }

        return try JSONDecoder().decode([Rate].self, from: data)
    }
}
