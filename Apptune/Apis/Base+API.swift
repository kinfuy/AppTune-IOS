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

// 空响应类型
struct EmptyResponse: Decodable {}

class API {
  static let shared = API()

  let session: URLSession = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30
    config.timeoutIntervalForResource = 180
    return URLSession(configuration: config)
  }()

  func getToken() -> String? {
    let token = UserService.shared.auth.accessToken
    return token.isEmpty ? nil : token
  }

  func createRequest(url: String, method: String, body: [String: Any]?) throws -> URLRequest {
    print("🚀 API Request:")
    print("URL: \(url)")
    print("Method: \(method)")

    var urlString = url
    if method == "GET" && body != nil {
      let queryItems = body!.map { key, value in
        return "\(key)=\(value)"
      }.joined(separator: "&")

      urlString += urlString.contains("?") ? "&" : "?"
      urlString += queryItems
      print("GET 请求参数: \(queryItems)")
    }

    guard let url = URL(string: urlString) else {
      throw APIError.serveError(code: "999999", message: "无效的请求地址")
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    if let token = getToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    print("请求头: \(request.allHTTPHeaderFields ?? [:])")

    if method != "GET" && body != nil {
      let jsonData = try JSONSerialization.data(withJSONObject: body ?? {}, options: [])
      request.httpBody = jsonData

      if let bodyString = String(data: jsonData, encoding: .utf8) {
        print("请求体: \(bodyString)")
      }
    }

    print("📡 请求完整信息:")
    print("----------------------------------------")
    print("\(request.curlString)")
    print("----------------------------------------")

    return request
  }

  func refreshAccessToken() async throws {
    let refreshToken = UserService.shared.auth.refreshToken
    let accessToken = UserService.shared.auth.accessToken

    guard !refreshToken.isEmpty else {
      await Router.shared.navigate(to: .login)
      throw APIError.serveError(code: "100006", message: "登录已过期，请重新登录")
    }

    let url = "\(BASR_SERVE_URL)/refreshToken"
    let request = try createRequest(
      url: url,
      method: "POST",
      body: ["refreshToken": refreshToken, "accessToken": accessToken]
    )

    do {
      let tokens: TokenInfo = try await URLSession.shared.data(for: request)
      UserService.shared.setToken(access: tokens.accessToken, refresh: tokens.refreshToken)
    } catch {
      await Router.shared.navigate(to: .login)
      throw APIError.serveError(code: "100006", message: "Token刷新失败")
    }
  }
}

// 添加一个扩展来生成 cURL 命令字符串
extension URLRequest {
  var curlString: String {
    guard let url = url else { return "" }
    var baseCommand = "curl \"\(url.absoluteString)\""

    if httpMethod == "HEAD" {
      baseCommand += " -I"
    }

    var command = [baseCommand]

    if let method = httpMethod, method != "GET" && method != "HEAD" {
      command.append("-X \(method)")
    }

    if let headers = allHTTPHeaderFields {
      for (key, value) in headers {
        command.append("-H \"\(key): \(value)\"")
      }
    }

    if let bodyData = httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
      command.append("-d '\(bodyString)'")
    }

    return command.joined(separator: " \\\n\t")
  }
}
