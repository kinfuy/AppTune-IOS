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
  case serveError(code: String, message: String)
}

struct VoidCodable: Decodable {}

extension URLSession {
  struct Response<T: Decodable>: Decodable {
    var message: String
    var code: String
    var data: T?
  }

  func data<T: Decodable>(for urlRequest: URLRequest, retrying: Bool = false) async throws -> T {
    do {
      // 检查网络连接
      if !CheckInternetConnection.isConnected() {
        try await Task.sleep(nanoseconds: 1)
        if !CheckInternetConnection.isConnected() {
          await Router.shared.openNotice(open: .toast(Toast(msg: "网络连接失败")))
          throw APIError.serveError(code: "999999", message: "网络连接失败")
        }
      }

      let (data, response) = try await self.data(for: urlRequest)
      guard let response = response as? HTTPURLResponse else {
        await Router.shared.openNotice(open: .toast(Toast(msg: "无效的请求")))
        throw APIError.serveError(code: "999999", message: "无效的请求")
      }

      guard 200...299 ~= response.statusCode else {
        await Router.shared.openNotice(open: .toast(Toast(msg: "HTTP错误: \(response.statusCode)")))
        throw APIError.serveError(code: "999999", message: "请求失败")
      }

      let res = try JSONDecoder().decode(Response<T>.self, from: data)

      switch res.code {
      case "000000":
        guard let responseData = res.data else {
          throw APIError.serveError(code: res.code, message: "数据为空")
        }
        return responseData

      case "100004":  // token过期
        if !retrying {
          try await APIManager.shared.refreshAccessToken()
          var newRequest = urlRequest
          if let token = APIManager.shared.getToken() {
            newRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          }
          return try await self.data(for: newRequest, retrying: true)
        }
        await Router.shared.navigate(to: .login)
        throw APIError.serveError(code: res.code, message: "登录已过期")

      case "100006":  // 需要重新登录
        await Router.shared.navigate(to: .login)
        throw APIError.serveError(code: res.code, message: "请重新登录")

      default:
        await Router.shared.openNotice(open: .toast(Toast(msg: res.message)))
        throw APIError.serveError(code: res.code, message: res.message)
      }

    } catch let error as APIError {
      throw error
    } catch {
        await Router.shared.openNotice(open: .toast(Toast(msg: error.localizedDescription)))
        throw APIError.serveError(code: "999999", message: error.localizedDescription)
    }
  }
}
