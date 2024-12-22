//
//  User+Api.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/21.
//
import Foundation

// MARK: - Models
struct UserResponse: Decodable {
  var id: String
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

// MARK: - API Methods
extension API {
  // 发送验证码
  static func sendCode(email: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/sendCode",
      method: "POST",
      body: ["email": email]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 登录/注册
  static func sign(email: String, password: String, code: String) async throws -> UserResponse {
    do {
      let response: UserResponse
      if code.isEmpty {
        response = try await login(email: email, password: password)
      } else {
        response = try await register(email: email, password: password, code: code)
      }

      UserService.shared.setToken(
        access: response.accessToken ?? "",
        refresh: response.refreshToken ?? ""
      )

      await UserService.shared.updateProfile(
        UserProfile(
          id: response.id,
          email: response.email,
          role: response.role,
          name: response.name,
          avatar: response.avatar,
          mobile: response.mobile,
          sex: response.sex
        )
      )

      await UserService.shared.updateStats(
        UserStats(
          follow: response.follow ?? 0,
          fans: response.fans ?? 0,
          coin: response.coin ?? 0
        )
      )

      return response
    } catch {
      UserService.shared.clearToken()
      throw error
    }
  }

  // Apple登录
  static func signApple(idToken: String, email: String?, name: String?) async throws -> UserResponse
  {
    var params: [String: Any] = ["idToken": idToken]
    if let email = email {
      params["email"] = email
    }
    if let name = name {
      params["name"] = name
    }

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/loginByApple",
      method: "POST",
      body: params
    )

    do {
      let response: UserResponse = try await API.shared.session.data(for: request)

      UserService.shared.setToken(
        access: response.accessToken ?? "",
        refresh: response.refreshToken ?? ""
      )

      await UserService.shared.updateProfile(
        UserProfile(
          id: response.id,
          email: response.email,
          role: response.role,
          name: response.name,
          avatar: response.avatar,
          mobile: response.mobile,
          sex: response.sex
        )
      )

      await UserService.shared.updateStats(
        UserStats(
          follow: response.follow ?? 0,
          fans: response.fans ?? 0,
          coin: response.coin ?? 0
        )
      )

      return response
    } catch {
      UserService.shared.clearToken()
      throw error
    }
  }

  // 获取用户信息
  static func fetchUserInfo(email: String) async throws -> UserResponse {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/user/userInfo",
      method: "POST",
      body: ["email": email]
    )
    let response: UserResponse = try await API.shared.session.data(for: request)

    await UserService.shared.updateProfile(
      UserProfile(
        id: response.id,
        email: response.email,
        role: response.role,
        name: response.name,
        avatar: response.avatar,
        mobile: response.mobile,
        sex: response.sex
      )
    )

    await UserService.shared.updateStats(
      UserStats(
        follow: response.follow ?? 0,
        fans: response.fans ?? 0,
        coin: response.coin ?? 0
      )
    )

    return response
  }

  // 更新用户信息
  @discardableResult
  static func updateUserInfo(_ info: [String: Any]) async throws -> UserResponse {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/user/update",
      method: "POST",
      body: info
    )
    return try await API.shared.session.data(for: request)
  }

  // MARK: - Private Methods
  private static func login(email: String, password: String) async throws -> UserResponse {
    let psd = MD5(string: "\(email)\(password)")
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/login",
      method: "POST",
      body: ["email": email, "password": psd]
    )
    return try await API.shared.session.data(for: request)
  }

  private static func register(email: String, password: String, code: String) async throws
    -> UserResponse
  {
    let psd = MD5(string: "\(email)\(password)")
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/register",
      method: "POST",
      body: ["email": email, "password": psd, "code": code]
    )
    return try await API.shared.session.data(for: request)
  }
}
