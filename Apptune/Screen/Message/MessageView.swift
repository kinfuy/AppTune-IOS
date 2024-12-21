//
//  MessageView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/21.
//

import SwiftUI

struct MessageView: View {
  @EnvironmentObject var userService: UserService
  // 主要功能入口
  struct MessageEntrance: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let type: MessageType
  }

  // 消息类型
  enum MessageType {
    case follow, signup, review
    case chat, official
  }

  // 主要功能入口数据
  var entrances: [MessageEntrance] {
    let items = [
      MessageEntrance(icon: "calendar", title: "报名", type: .signup),
      MessageEntrance(icon: "shield.checkerboard", title: "审核", type: .review),
      MessageEntrance(icon: "person.2.fill", title: "关注", type: .follow),
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
    .background(Color.gray.opacity(0.05))
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
        EntranceCell(icon: entrance.icon, title: entrance.title, type: entrance.type)
      }
    }
    .padding(.horizontal)
  }

  // 消息列表
  private var messageList: some View {
    VStack(spacing: 16) {
      // 官方消息组
      MessageRowLink(
        icon: "megaphone.fill",
        title: "官方消息",
        subtitle: "平台公告与系统通知",
        iconColor: .orange
      )
    }
  }
}

// 功能入口单元格
struct EntranceCell: View {
  let icon: String
  let title: String
  let type: MessageView.MessageType

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

  var body: some View {
    VStack(spacing: 8) {
      Circle()
        .fill(themeColor.opacity(0.1))
        .frame(width: 48, height: 48)
        .overlay(
          Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundColor(themeColor)
        )

      Text(title)
        .font(.system(size: 14))
        .foregroundColor(.black.opacity(0.75))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
  }
}

// 消息列表行
struct MessageRowLink: View {
  let icon: String
  let title: String
  let subtitle: String
  let iconColor: Color

  var body: some View {
    NavigationLink(destination: EmptyView()) {
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

        // 未读消息数
        if true {
          Circle()
            .fill(Color.red)
            .frame(width: 16, height: 16)
            .overlay(
              Text("2")
                .font(.system(size: 11))
                .foregroundColor(.white)
            )
        }

        Image(systemName: "chevron.right")
          .font(.system(size: 12))
          .foregroundColor(.gray)
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(Color.white.opacity(0.5))
      .cornerRadius(8)
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal)
  }
}

#Preview {
  MessageView()
    .environmentObject(UserService())

}
