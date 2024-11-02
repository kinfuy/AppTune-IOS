//
//  User+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//
import SwiftUI

struct UserInfo {
  var email: String
  var role: String
  var name: String
  var avatar: String
  var follow: Int
  var fans: Int
  var coin: Int
  var accessToken: String
  var refreshToken: String
}

class UserService: ObservableObject {
  static let shared = UserService()

  init() {
    let loginEmail = UserDefaults.standard.string(forKey: "loginEmail")
    let accessToken = UserDefaults.standard.string(forKey: "accessToken")
    let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")

    if let loginEmail = loginEmail,
      let accessToken = accessToken,
      let refreshToken = refreshToken,
      !loginEmail.isEmpty && !accessToken.isEmpty && !refreshToken.isEmpty
    {
      isLogin = true
      self.user.email = loginEmail
      self.user.accessToken = accessToken
      self.user.refreshToken = refreshToken
    }
  }

  @Published var isLogin = false

  @Published var user: UserInfo = UserInfo(
    email: "",
    role: "",
    name: "--",
    avatar: "p_8",
    follow: 0,
    fans: 0,
    coin: 0,
    accessToken: "",
    refreshToken: ""
  )

  func logout() {
    isLogin = false
    clearUserData()
    clearToken()
  }

  func login(u: UserInfo) {
    isLogin = true
    updateUserInfo(u)
    saveUserDefaults()
  }

  func setToken(access: String, refresh: String) {
    user.accessToken = access
    user.refreshToken = refresh
    UserDefaults.standard.set(access, forKey: "accessToken")
    UserDefaults.standard.set(refresh, forKey: "refreshToken")
  }

  func clearToken() {
    user.accessToken = ""
    user.refreshToken = ""
    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "refreshToken")
  }

  func loadUser() async throws {
    if !isLogin || user.email.isEmpty { return }

    do {
      let u = try await UserAPI.shared.fetchUserInfo(email: user.email)
      DispatchQueue.main.async {
        self.updateUserInfo(
          UserInfo(
            email: u.email,
            role: u.role,
            name: u.name,
            avatar: u.avatar,
            follow: self.user.follow,
            fans: self.user.fans,
            coin: self.user.coin,
            accessToken: self.user.accessToken,
            refreshToken: self.user.refreshToken
          ))
      }
    } catch let APIError.serveError(code, _) {
      if code == "100004" || code == "100006" {
        DispatchQueue.main.async {
          self.logout()
        }
      }
    }
  }

  private func clearUserData() {
    user = UserInfo(
      email: "",
      role: "",
      name: "--",
      avatar: "p_8",
      follow: 0,
      fans: 0,
      coin: 0,
      accessToken: "",
      refreshToken: ""
    )
    UserDefaults.standard.removeObject(forKey: "loginEmail")
    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "refreshToken")
  }

  private func updateUserInfo(_ u: UserInfo) {
    user.avatar = u.avatar
    user.email = u.email
    user.role = u.role
    user.name = u.name
    user.follow = u.follow
    user.fans = u.fans
    user.coin = u.coin
    if !u.accessToken.isEmpty {
      user.accessToken = u.accessToken
    }
    if !u.refreshToken.isEmpty {
      user.refreshToken = u.refreshToken
    }
  }

  private func saveUserDefaults() {
    UserDefaults.standard.set(user.email, forKey: "loginEmail")
    UserDefaults.standard.set(user.accessToken, forKey: "accessToken")
    UserDefaults.standard.set(user.refreshToken, forKey: "refreshToken")
  }
}
