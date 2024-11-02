//
//  User+Api.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/21.
//
import Foundation

struct UserResponse: Decodable {
  var email: String
  var role: String
  var name: String
  var avatar: String
  var mobile: String?
  var sex: Int?

  var accessToken: String?
  var refreshToken: String?

  var follow: Int?
  var fans: Int?
  var coin: Int?
}

class UserAPI {
  static let shared = UserAPI()
  private let apiManager = APIManager.shared

  func sendCode(email: String) async throws {
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/sendCode",
      method: "POST",
      body: ["email": email]
    )
    _ = try await apiManager.session.data(for: request) as VoidCodable
  }

  func sign(email: String, password: String, code: String) async throws -> UserResponse {
    do {
      let response: UserResponse
      if code.isEmpty {
        response = try await login(email: email, password: password)
      } else {
        response = try await register(email: email, password: password, code: code)
      }

      UserService.shared.setToken(
        access: response.accessToken ?? "", refresh: response.refreshToken ?? "")

      UserService.shared.updateProfile(
        UserProfile(
          email: response.email,
          role: response.role,
          name: response.name,
          avatar: response.avatar,
          mobile: response.mobile,
          sex: response.sex
        ))

      UserService.shared.updateStats(
        UserStats(
          follow: response.follow ?? 0,
          fans: response.fans ?? 0,
          coin: response.coin ?? 0
        ))

      return response
    } catch {
      UserService.shared.clearToken()
      throw error
    }
  }

  func fetchUserInfo(email: String) async throws -> UserResponse {
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/user/userInfo",
      method: "POST",
      body: ["email": email]
    )
    let response: UserResponse = try await apiManager.session.data(for: request)

    UserService.shared.updateProfile(
      UserProfile(
        email: response.email,
        role: response.role,
        name: response.name,
        avatar: response.avatar,
        mobile: response.mobile,
        sex: response.sex
      ))

    UserService.shared.updateStats(
      UserStats(
        follow: response.follow ?? 0,
        fans: response.fans ?? 0,
        coin: response.coin ?? 0
      ))

    return response
  }

  private func login(email: String, password: String) async throws -> UserResponse {
    let psd = MD5(string: "\(email)\(password)")
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/login",
      method: "POST",
      body: ["email": email, "password": psd]
    )
    return try await apiManager.session.data(for: request)
  }

  private func register(email: String, password: String, code: String) async throws
    -> UserResponse
  {
    let psd = MD5(string: "\(email)\(password)")
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/register",
      method: "POST",
      body: ["email": email, "password": psd, "code": code]
    )
    return try await apiManager.session.data(for: request)
  }

  @discardableResult
  func updateUserInfo(_ info: [String: Any]) async throws -> UserResponse {
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/user/update",
      method: "POST",
      body: info
    )
    return try await apiManager.session.data(for: request)
  }
}
