//
//  Base+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/24.
//

import Foundation

struct TokenInfo: Decodable {
    var accessToken: String
    var refreshToken: String
}

class APIManager {
    static let shared = APIManager()

    let session = URLSession(configuration: .default)

    // Access the token via UserService
    private var token: String? {
        return UserService.shared.user.accessToken
    }

    func createRequest(url: String, method: String, body: [String: Any]?) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw APIError.invaldURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        }

        return request
    }

    func refreshAccessToken() async throws {
        let refreshToken = UserService.shared.user.refreshToken
        guard !refreshToken.isEmpty else {
            throw APIError.unauthorized("Refresh token is missing")
        }

        let url = "\(BASR_SERVE_URL)/refreshToken"
        let request = try createRequest(url: url, method: "POST", body: ["refreshToken": refreshToken])

        let tokens: TokenInfo? = try await URLSession.shared.data(for: request)

        if let tokens = tokens {
            UserService.shared.setToken(access: tokens.accessToken, refresh: tokens.refreshToken)
        } else {
            throw APIError.serveError("Failed to refresh tokens")
        }
    }
}
