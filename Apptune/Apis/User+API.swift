//
//  User+Api.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/21.
//
import Foundation

struct UserInforResponse: Decodable {
    var email: String
    var role: String
    var name: String
    var accessToken: String
    var refreshToken: String
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
        let _ = try await apiManager.session.data<VoidCodable>(for: request)
    }

    func sign(email: String, password: String, code: String) async throws -> UserInforResponse {
        if code.isEmpty {
            return try await login(email: email, password: password)
        } else {
            return try await register(email: email, password: password, code: code)
        }
    }

    private func login(email: String, password: String) async throws -> UserInforResponse {
        let psd = MD5(string: "\(email)\(password)")
        let request = try apiManager.createRequest(
            url: "\(BASR_SERVE_URL)/login",
            method: "POST",
            body: ["email": email, "password": psd]
        )
        return try await apiManager.session.data<UserInforResponse>(for: request)!
    }

    private func register(email: String, password: String, code: String) async throws -> UserInforResponse {
        let psd = MD5(string: "\(email)\(password)")
        let request = try apiManager.createRequest(
            url: "\(BASR_SERVE_URL)/register",
            method: "POST",
            body: ["email": email, "password": psd, "code": code]
        )
        return try await apiManager.session.data<UserInforResponse>(for: request)!
    }
}
