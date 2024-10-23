//
//  User+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//
import SwiftUI

struct UserInfo {
    var username: String
    var avator: String
    var follow: Int
    var fans: Int
    var coin: Int
}

class UserService: ObservableObject  {
    static let shared = UserService()

    @Published var isLogin = false

    @Published var user: UserInfo = UserInfo(
        username: "--",
        avator: "user",
        follow: 0,
        fans: 0,
        coin: 0
    )
}
