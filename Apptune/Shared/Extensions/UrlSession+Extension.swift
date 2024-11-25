//
//  Url.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/6/22.
//

import Foundation
import SwiftyJSON

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
  case systemError(message: String)
}

struct VoidCodable: Decodable {}

extension URLSession {
  struct Response<T: Decodable>: Decodable {
    var message: String
    var code: String
    var data: T?
  }

  // 先定义一个基础响应结构
  private struct BaseResponse: Decodable {
    var message: String
    var code: String
    var data: AnyCodable?
  }

  @discardableResult
  func data<T: Decodable>(for urlRequest: URLRequest, retrying: Bool = false, loading: Bool = true)
    async throws -> T
  {
    var loadId: String?
    do {
      if loading {
        loadId = await NoticeManager.shared.openNotice(
          open: .loading("", theme: .custom(background: .clear, textColor: .gray)))
      }

      // 检查网络连接
      let isConnected = await CheckInternetConnection.checkConnection()
      guard isConnected else {
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "网络连接失败")))
        throw APIError.systemError(message: "网络连接失败")
      }

      let (data, response) = try await self.data(for: urlRequest)

      if let jsonString = String(data: data, encoding: .utf8) {
        print("🌍 API Response Raw Data:")
        print("URL: \(urlRequest.url?.absoluteString ?? "")")
        print("Method: \(urlRequest.httpMethod ?? "")")
        print("Response: \(jsonString)")
      }

      guard let response = response as? HTTPURLResponse else {
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "无效的请求")))
        throw APIError.systemError(message: "无效的请求")
      }

      guard 200...299 ~= response.statusCode else {
        print("🌍 API Response Status Code: \(response.statusCode)")
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "服务异常，请稍后重试")))
        throw APIError.systemError(message: "请求失败")
      }

      let decoder = JSONDecoder()
      let baseResponse = try decoder.decode(BaseResponse.self, from: data)

      // 检查业务状态码
      if baseResponse.code != "000000" {
        switch baseResponse.code {
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
          await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "登录已过期")))
          throw APIError.serveError(code: baseResponse.code, message: "登录已过期")

        case "100006":  // 需要重新登录
          await Router.shared.navigate(to: .login)
          await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "请重新登录")))
          throw APIError.serveError(code: baseResponse.code, message: "请重新登录")

        default:
          await NoticeManager.shared.openNotice(open: .toast(Toast(msg: baseResponse.message)))
          throw APIError.serveError(code: baseResponse.code, message: baseResponse.message)
        }
      }

      guard let responseData = baseResponse.data else {
        if T.self == VoidCodable.self {
          if loadId != "" {
            await NoticeManager.shared.closeNotice(id: loadId)
          }
          return VoidCodable() as! T
        }
        throw APIError.systemError(message: "数据为空")
      }

      // 解析具体数据
      let responseObject: T
      do {
        if T.self == VoidCodable.self {
          responseObject = VoidCodable() as! T
        } else {
          let json = JSON(responseData.value)

          if let jsonData = try? json.rawData() {
            decoder.dateDecodingStrategy = .millisecondsSince1970
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            responseObject = try decoder.decode(T.self, from: jsonData)
            print("sss222s", responseObject)
          } else {
            throw APIError.systemError(message: "JSON 序列化失败")
          }
        }
      } catch {
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "数据解析失败")))
        throw APIError.systemError(message: "数据解析失败")
      }

      if loadId != "" {
        await NoticeManager.shared.closeNotice(id: loadId)
      }

      return responseObject

    } catch {
      if let loading = loadId {
        await NoticeManager.shared.closeNotice(id: loading)
      }

      // 处理超时错误
      if (error as NSError).code == NSURLErrorTimedOut {
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "请求超时，请稍后重试")))
        throw APIError.systemError(message: "请求超时")
      }

      // 处理其他网络错误
      if (error as NSError).domain == NSURLErrorDomain {
        await NoticeManager.shared.openNotice(open: .toast(Toast(msg: "网络请求失败")))
        throw APIError.systemError(message: "网络请求失败")
      }

      throw error
    }
  }
}

// 用于处理任意JSON数据的辅助结构
private struct AnyCodable: Codable {
  let value: Any

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self.value = NSNull()
    } else if let bool = try? container.decode(Bool.self) {
      self.value = bool
    } else if let int = try? container.decode(Int.self) {
      self.value = int
    } else if let double = try? container.decode(Double.self) {
      self.value = double
    } else if let string = try? container.decode(String.self) {
      self.value = string
    } else if let array = try? container.decode([AnyCodable].self) {
      self.value = array.map { $0.value }
    } else if let dictionary = try? container.decode([String: AnyCodable].self) {
      self.value = dictionary.mapValues { $0.value }
    } else {
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "AnyCodable value cannot be decoded")
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch value {
    case is NSNull:
      try container.encodeNil()
    case let bool as Bool:
      try container.encode(bool)
    case let int as Int:
      try container.encode(int)
    case let double as Double:
      try container.encode(double)
    case let string as String:
      try container.encode(string)
    case let array as [Any]:
      try container.encode(array.map { AnyCodable(value: $0) })
    case let dictionary as [String: Any]:
      try container.encode(dictionary.mapValues { AnyCodable(value: $0) })
    default:
      throw EncodingError.invalidValue(
        value,
        EncodingError.Context(
          codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
    }
  }

  init(value: Any) {
    self.value = value
  }
}

// 添加一个辅助方法用于手动解析
private func parseJSON(_ json: JSON) throws -> Any {
  switch json.type {
  case .array:
    return try json.arrayValue.map { try parseJSON($0) }
  case .dictionary:
    var dict = [String: Any]()
    for (key, value) in json {
      dict[key] = try parseJSON(value)
    }
    return dict
  case .string:
    return json.stringValue
  case .number:
    return json.numberValue
  case .bool:
    return json.boolValue
  case .null:
    return NSNull()
  default:
    throw APIError.systemError(message: "未支持的 JSON 类型")
  }
}
