//
//  NotificationView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/21.
//

import SwiftUI

struct NotificationView: View {
  @EnvironmentObject var userService: UserService
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var noticeService: NotificationService
  // 主要功能入口
  struct MessageEntrance: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let type: MessageType
    let unread: Int
  }

  // 消息类型
  enum MessageType {
    case follow, signup, review
    case chat, official
  }

  // 主要功能入口数据
  var entrances: [MessageEntrance] {
    let items = [
      MessageEntrance(
        icon: "calendar", title: "报名", type: .signup, unread: noticeService.unreadCounts.join),
      MessageEntrance(
        icon: "shield.checkerboard", title: "审核", type: .review,
        unread: noticeService.unreadCounts.audit),
      MessageEntrance(
        icon: "person.2.fill", title: "关注", type: .follow, unread: noticeService.unreadCounts.follow
      ),
    ]
    return items
  }

  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text("消息中心")
          .font(.system(size: 28))
          .fontWeight(.bold)
        Spacer()
      }
      .padding(.horizontal)

      ScrollView {
        VStack(spacing: 20) {
          // 主要功能入口网格
          mainEntranceGrid

          // 消息列表
          messageList
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top)
    .background(Color(hex: "#f4f4f4"))
    .task {
      // 初始加载数据
      await noticeService.fetchUnreadCount()
    }
  }

  // 主要功能入口网格
  private var mainEntranceGrid: some View {
    LazyVGrid(
      columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
      ], spacing: 16
    ) {
      ForEach(entrances) { entrance in
        EntranceCell(
          icon: entrance.icon, title: entrance.title, type: entrance.type, unread: entrance.unread)
      }
    }
    .padding(.horizontal)
  }

  // 消息列表
  private var messageList: some View {
    VStack(spacing: 16) {
      MessageRowLink(
        icon: "megaphone.fill",
        title: "官方消息",
        subtitle: "平台公告与系统通知",
        iconColor: .orange,
        unreadCount: noticeService.unreadCounts.official
      )
    }
  }

  private func handleMessageTap(type: MessageType) {
    switch type {
    case .official:
      router.navigate(to: .officeNotice)
    case .follow:
      router.navigate(to: .followNotice)
    case .signup:
      router.navigate(to: .joinNotice)
    case .review:
      router.navigate(to: .auditNotice)
    default:
      break
    }
  }
}

// 功能入口单元格
struct EntranceCell: View {
  let icon: String
  let title: String
  let type: NotificationView.MessageType
  let unread: Int
  @EnvironmentObject private var router: Router
  // 根据类型返回不同的颜色
  private var themeColor: Color {
    switch type {
    case .signup:
      return .blue
    case .follow:
      return .green
    case .review:
      return .orange
    default:
      return .blue
    }
  }

  private var unreadBadge: some View {
    Group {
      if unread > 0 {
        Text(unread > 99 ? "99+" : "\(unread)")
          .font(.system(size: 11))
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.red)
          .clipShape(Capsule())
          .overlay(
            Capsule()
              .stroke(Color.white, lineWidth: 1)
          )
      }
    }
  }

  var body: some View {
    Button(action: {
      navigateToNotice()
    }) {
      VStack(spacing: 8) {
        Circle()
          .fill(themeColor.opacity(0.1))
          .frame(width: 48, height: 48)
          .overlay(
            Image(systemName: icon)
              .font(.system(size: 20))
              .foregroundColor(themeColor)
          )
          .overlay(
            unreadBadge
              .offset(x: 16, y: 5),
            alignment: .topTrailing
          )

        Text(title)
          .font(.system(size: 14))
          .foregroundColor(.black.opacity(0.75))
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
  }

  private func navigateToNotice() {
    switch type {
    case .follow:
      router.navigate(to: .followNotice)
    case .signup:
      router.navigate(to: .joinNotice)
    case .review:
      router.navigate(to: .auditNotice)
    default:
      break
    }
  }
}

// 消息列表行
struct MessageRowLink: View {
  let icon: String
  let title: String
  let subtitle: String
  let iconColor: Color
  let unreadCount: Int
  @EnvironmentObject private var router: Router

  private var unreadBadge: some View {
    Group {
      if unreadCount > 0 {
        Text(unreadCount > 99 ? "99+" : "\(unreadCount)")
          .font(.system(size: 11))
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.red)
          .clipShape(Capsule())
      }
    }
  }

  var body: some View {
    HStack(spacing: 12) {
      // 图标
      Circle()
        .fill(iconColor.opacity(0.1))
        .frame(width: 44, height: 44)
        .overlay(
          Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(iconColor)
        )

      // 文本内容
      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.system(size: 15, weight: .medium))

        Text(subtitle)
          .font(.system(size: 13))
          .foregroundColor(.gray)
      }

      Spacer()

      // 替换原有的未读消息显示
      unreadBadge

      Image(systemName: "chevron.right")
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color.white.opacity(0.5))
    .cornerRadius(8)
    .padding(.horizontal)
    .contentShape(Rectangle())
    .onTapGesture {
      router.navigate(to: .officeNotice)
    }
  }
}

#Preview {
  NotificationView()
    .environmentObject(UserService())
    .environmentObject(Router.shared)
    .environmentObject(NotificationService())
}
