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
    var avator: String?
    var follow: Int
    var fans: Int
    var coin: Int
    var accessToken: String
    var refreshToken: String
}

class UserService: ObservableObject {
    static let shared = UserService()

    @Published var isLogin = false

    @Published var user: UserInfo = UserInfo(
        email: "",
        role: "",
        name: "--",
        follow: 0,
        fans: 0,
        coin: 0,
        accessToken: "",
        refreshToken: ""
    )

    func login(u: UserInfo) {
        isLogin = true
        user.avator = u.avator ?? "user"
        user.email = u.email
        user.role = u.role
        user.name = u.name
        user.follow = u.follow
        user.fans = u.fans
        user.coin = u.coin
        user.accessToken = u.accessToken
        user.refreshToken = u.refreshToken
    }

    func setToken(access: String, refresh: String) {
        user.accessToken = access
        user.refreshToken = refresh
    }
}
