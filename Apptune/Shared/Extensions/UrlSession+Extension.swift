//
//  Url.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/6/22.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(string: value.description)!
    }
}

extension URLSession {
    static var imageSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = .shared
        return URLSession(configuration: config)
    }()
}

enum APIError: Error {
    case invaldURL
    case invaldCode(Int)
    case serveError(String)
    case noNetwork(String)

    var description: String {
        switch self {
        case .noNetwork:
            return "无网络链接"
        case .invaldURL:
            return "无效的请求地址"
        case .invaldCode:
            return "Error: \(localizedDescription)"
        case .serveError:
            return "\(localizedDescription)"
        }
    }
}

struct VoidCodable: Decodable {}

extension URLSession {
    struct Response<T: Decodable>: Decodable {
        var message: String
        var code: String
        var data: T?
    }

    func data(for urlRequest: URLRequest) async throws {
        
        // 检查网络连接状态
        var isConnected = CheckInternetConnection.isConnected()

        if !isConnected {
            try await Task.sleep(nanoseconds: 1)
            isConnected = CheckInternetConnection.isConnected()
        }

        if !isConnected {
            throw APIError.noNetwork("网络连接失败")
        }
        
        let (data, response) = try await self.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else { throw APIError.invaldURL }
        guard 200 ... 299 ~= response.statusCode else { throw APIError.invaldCode(response.statusCode) }
        
        // Attempt to decode to Response<Void> with no 'data'
        let res = try JSONDecoder().decode(Response<VoidCodable>.self, from: data)
        
        guard res.code == "000000" else {
            throw APIError.serveError(res.message)
        }
    }
}
