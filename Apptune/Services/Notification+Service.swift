//
//  Message+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import Foundation
import SwiftUI

@MainActor
class NotificationService: ObservableObject {
  // 未读消息数
  @Published var unreadCounts: UnreadCountResponse = UnreadCountResponse(
    join: 0, audit: 0, follow: 0, official: 0)

  // 加载状态
  @Published var isLoading = false

  // 获取未读消息数
  func fetchUnreadCount() async {
    do {
      unreadCounts = try await API.getUnreadCount()
    } catch {
      print("获取未读消息数失败:", error)
    }
  }

  // 标记所有消息已读
  func markAllAsRead() async {
    do {
      try await API.markAllMessagesAsRead()
      await fetchUnreadCount()
    } catch {
      print("标记所有消息已读失败:", error)
    }
  }

  // 删除所有消息
  func deleteAllMessages(type: NotificationType) async {
    do {
      try await API.deleteAllMessages(type: type)
    } catch {
      print("删除所有消息失败:", error)
    }
  }
}
