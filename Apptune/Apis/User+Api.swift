//
//  User+Api.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/21.
//
import Foundation

class UserAPI {
    static let shared = UserAPI()
    private let session = URLSession(configuration: .default)
    
    func sendCode(email: String) async throws  {
        let url = "\(BASR_SERVE_URL)/sendCode"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
//        request.addValue("ios_app", forHTTPHeaderField: "app-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONSerialization.data(
            withJSONObject: ["email": email], options: [])
        request.httpBody = jsonData
        return try await session.data(for: request)
    }
}
