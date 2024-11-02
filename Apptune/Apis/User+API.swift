//
//  User+Api.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/21.
//
import Foundation

struct UserLoginResponse: Decodable {
  var email: String
  var role: String
  var name: String
  var avatar: String
  var accessToken: String
  var refreshToken: String
}

struct UserInfoResponse: Decodable {
  var email: String
  var role: String
  var name: String
  var avatar: String
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

  func sign(email: String, password: String, code: String) async throws -> UserLoginResponse {
    do {
      let response: UserLoginResponse
      if code.isEmpty {
        response = try await login(email: email, password: password)
      } else {
        response = try await register(email: email, password: password, code: code)
      }

      UserService.shared.setToken(
        access: response.accessToken,
        refresh: response.refreshToken
      )

      return response
    } catch {
      UserService.shared.clearToken()
      throw error
    }
  }

  func fetchUserInfo(email: String) async throws -> UserInfoResponse {
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/user/userInfo",
      method: "POST",
      body: ["email": email]
    )
    return try await apiManager.session.data(for: request)
  }

  private func login(email: String, password: String) async throws -> UserLoginResponse {
    let psd = MD5(string: "\(email)\(password)")
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/login",
      method: "POST",
      body: ["email": email, "password": psd]
    )
    return try await apiManager.session.data(for: request)
  }

  private func register(email: String, password: String, code: String) async throws
    -> UserLoginResponse
  {
    let psd = MD5(string: "\(email)\(password)")
    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/register",
      method: "POST",
      body: ["email": email, "password": psd, "code": code]
    )
    return try await apiManager.session.data(for: request)
  }
}
