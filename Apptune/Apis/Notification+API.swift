//
//  Message+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import Foundation

// MARK: - Models
struct Notification: Codable, Identifiable {
  let id: String
  let userId: String
  let title: String
  let content: String
  let type: NotificationType
  let targetId: String?
  let targetType: NotificationTargetType?
  let isRead: Bool
  let isDelete: Bool
  let createTime: Date
  let updateTime: Date
}

enum NotificationType: String, Codable {
  case join  // 活动报名
  case audit  // 活动审核
  case follow  // 关注
  case official  // 官方通知
}

enum NotificationTargetType: String, Codable {
  case active
}

struct QueryMessageParams: Codable {
  var type: NotificationType?
  var page: Int = 1
  var pageSize: Int = 20
}

struct UnreadCountResponse: Codable {
  let join: Int
  let audit: Int
  let follow: Int
  let official: Int
}

// MARK: - API Methods
extension API {
  // 获取消息列表
  static func fetchMessages(params: QueryMessageParams) async throws -> ListResponse<Notification> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/notification/list",
      method: "GET",
      body: params.asDictionary()
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取未读消息数
  static func getUnreadCount() async throws -> UnreadCountResponse {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/notification/unreadCount",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // 标记消息已读
  static func markMessageAsRead(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/notification/read/\(id)",
      method: "POST",
      body: nil
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 标记所有消息已读
  static func markAllMessagesAsRead() async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/notification/readAll",
      method: "POST",
      body: nil
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }
}
