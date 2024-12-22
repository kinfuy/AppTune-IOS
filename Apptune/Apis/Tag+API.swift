//
//  Tag+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/24.
//

import SwiftUI

// MARK: - Models
struct TagInfo: Codable, Identifiable {
  let id: String
  let name: String
  let color: String
  let type: String
  let userId: String?
  let createTime: TimeInterval
}

// MARK: - API Methods
extension API {
  // 创建标签
  static func createTag(name: String, color: String, type: String? = nil) async throws -> TagInfo {
    let params = [
      "name": name,
      "color": color,
      "type": type,
    ].compactMapValues { $0 }

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/tags/create",
      method: "POST",
      body: params
    )

    return try await API.shared.session.data(for: request)
  }

  // 获取公共标签
  static func getPublicTags() async throws -> [TagInfo] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/tags/public",
      method: "GET",
      body: nil
    )

    return try await API.shared.session.data(for: request)
  }

  // 获取私有标签
  static func getPrivateTags() async throws -> [TagInfo] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/tags/private",
      method: "GET",
      body: nil
    )

    return try await API.shared.session.data(for: request)
  }

  // 获取用户所有可见标签
  static func getUserTags() async throws -> [TagInfo] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/tags/my",
      method: "GET",
      body: nil
    )

    return try await API.shared.session.data(for: request)
  }

  // 删除标签
  static func deleteTag(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/tags/delete",
      method: "POST",
      body: ["id": id]
    )

    let _: VoidCodable = try await API.shared.session.data(for: request)
  }
}
