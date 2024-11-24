//
//  Tag+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/24.
//

import SwiftUI

struct TagInfo: Codable, Identifiable {
    let id: String
    let name: String
    let color: String
    let type: String
    let userId: String?
    let createTime: TimeInterval
}

class TagAPI {
    static let shared = TagAPI()
    private let apiManager = APIManager.shared
    
    // 创建标签
    func createTag(name: String, color: String, type: String? = nil) async throws -> TagInfo {
        let urlString = "\(BASR_SERVE_URL)/tags/create"
        
        let body = [
            "name": name,
            "color": color,
            "type": type
        ]
        
        let request = try apiManager.createRequest(
            url: urlString,
            method: "POST",
            body: body as [String : Any]
        )
        
        return try await apiManager.session.data(for: request)
    }
    
    // 获取公共标签
    func getPublicTags() async throws -> [TagInfo] {
        let urlString = "\(BASR_SERVE_URL)/tags/public"
        
        let request = try apiManager.createRequest(
            url: urlString,
            method: "GET",
            body: nil
        )
        
        return try await apiManager.session.data(for: request)
    }
    
    // 获取私有标签
    func getPrivateTags() async throws -> [TagInfo] {
        let urlString = "\(BASR_SERVE_URL)/tags/private"
        
        let request = try apiManager.createRequest(
            url: urlString,
            method: "GET",
            body: nil
        )
        
        return try await apiManager.session.data(for: request)
    }
    
    // 获取用户所有可见标签
    func getUserTags() async throws -> [TagInfo] {
        let urlString = "\(BASR_SERVE_URL)/tags/my"
        
        let request = try apiManager.createRequest(
            url: urlString,
            method: "GET",
            body: nil
        )
        
        return try await apiManager.session.data(for: request)
    }
    
    // 删除标签
    func deleteTag(id: String) async throws {
        let urlString = "\(BASR_SERVE_URL)/tags/delete"
        
        let body = [
            "id": id
        ]
        
        let request = try apiManager.createRequest(
            url: urlString,
            method: "POST",
            body: body
        )
        
        let _ = try await apiManager.session.data(for: request)
    }
}

