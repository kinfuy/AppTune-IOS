//
//  User+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//
import SwiftUI

// 基本用户信息
struct UserProfile {
  var email: String
  var role: String
  var name: String
  var avatar: String
  var mobile: String?
  var sex: Int?
}

// 用户统计信息
struct UserStats {
  var follow: Int
  var fans: Int
  var coin: Int
}

// 用户认证信息
struct UserAuth {
  var accessToken: String
  var refreshToken: String
}

class UserService: ObservableObject {
  static let shared = UserService()

  // MARK: - Published Properties

  @Published var isLogin = false
  @Published var profile: UserProfile
  @Published var stats: UserStats
  @Published var auth: UserAuth

  var isAdmin: Bool {
    return isLogin && profile.role == "admin"
  }

  var isDeveloper: Bool {
    return isLogin && profile.role == "developer"
  }

  // MARK: - Constants

  private let storage = UserDefaults.standard
  private enum StorageKeys {
    static let loginEmail = "loginEmail"
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
  }

  // MARK: - Initialization

  init() {
    // 初始化默认值
    profile = UserProfile(
      email: "",
      role: "",
      name: "--",
      avatar: "p_8",
      mobile: nil,
      sex: nil
    )

    stats = UserStats(
      follow: 0,
      fans: 0,
      coin: 0
    )

    auth = UserAuth(
      accessToken: "",
      refreshToken: ""
    )

    // 从本地存储恢复登录状态
    if let loginEmail = storage.string(forKey: StorageKeys.loginEmail),
      let accessToken = storage.string(forKey: StorageKeys.accessToken),
      let refreshToken = storage.string(forKey: StorageKeys.refreshToken),
      !loginEmail.isEmpty && !accessToken.isEmpty && !refreshToken.isEmpty
    {
      isLogin = true
      profile.email = loginEmail
      auth.accessToken = accessToken
      auth.refreshToken = refreshToken
    }
  }

  // MARK: - Authentication Methods

  @MainActor
  func login(response: UserResponse) {
    isLogin = true
    updateProfile(
      UserProfile(
        email: response.email,
        role: response.role,
        name: response.name,
        avatar: response.avatar,
        mobile: "",
        sex: 1
      ))
    setToken(access: response.accessToken ?? "", refresh: response.refreshToken ?? "")
    saveToStorage()
  }

  @MainActor
  func logout() {
    isLogin = false
    clearAll()
  }

  // MARK: - Token Management

  func setToken(access: String, refresh: String) {
    auth.accessToken = access
    auth.refreshToken = refresh
    storage.set(access, forKey: StorageKeys.accessToken)
    storage.set(refresh, forKey: StorageKeys.refreshToken)
  }

  func clearToken() {
    auth = UserAuth(accessToken: "", refreshToken: "")
    storage.removeObject(forKey: StorageKeys.accessToken)
    storage.removeObject(forKey: StorageKeys.refreshToken)
  }

  // MARK: - User Data Management

  @MainActor
  func updateProfile(_ newProfile: UserProfile) {
    profile = newProfile
  }

  @MainActor
  func updateStats(_ newStats: UserStats) {
    stats = newStats
  }

  // MARK: - Data Refresh

  func refreshUserInfo() async throws {
    guard isLogin && !profile.email.isEmpty else { return }

    do {
      let info = try await UserAPI.shared.fetchUserInfo(email: profile.email)
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.updateProfile(
          UserProfile(
            email: info.email,
            role: info.role,
            name: info.name,
            avatar: info.avatar,
            mobile: info.mobile,
            sex: info.sex
          ))
      }
    } catch let APIError.serveError(code, _) {
      if code == "100004" || code == "100006" {
        DispatchQueue.main.async { [weak self] in
          self?.logout()
        }
      }
      DispatchQueue.main.async {
        NoticeManager.shared.openNotice(open: .toast("刷新失败"))
      }
    }
  }

  // MARK: - Private Helper Methods

  private func clearAll() {
    // 清除用户资料
    profile = UserProfile(
      email: "",
      role: "",
      name: "--",
      avatar: "p_8",
      mobile: nil,
      sex: nil
    )

    // 清除统计数据
    stats = UserStats(
      follow: 0,
      fans: 0,
      coin: 0
    )

    // 清除认证信息
    clearToken()

    // 清除存储
    storage.removeObject(forKey: StorageKeys.loginEmail)
  }

  private func saveToStorage() {
    storage.set(profile.email, forKey: StorageKeys.loginEmail)
  }
}
