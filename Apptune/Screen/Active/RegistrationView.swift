//
//  RegistrationView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/23.
//

import SwiftUI

// 定义报名状态枚举
enum RegistrationStatus: String {
  case registered = "已报名"
  case pending = "待审核"
  case rejected = "已驳回"
  case completed = "已完成"

  // 获取状态对应的颜色
  var statusColor: Color {
    switch self {
    case .registered: return Color(.systemBlue).opacity(0.15)
    case .pending: return Color(.systemOrange).opacity(0.15)
    case .rejected: return Color(.systemRed).opacity(0.15)
    case .completed: return Color(.systemGreen).opacity(0.15)
    }
  }

  var textColor: Color {
    switch self {
    case .registered: return Color(.systemBlue)
    case .pending: return Color(.systemOrange)
    case .rejected: return Color(.systemRed)
    case .completed: return Color(.systemGreen)
    }
  }
}

// 用户报名信息模型
struct RegistrationUser: Identifiable {
  let id = UUID()
  let username: String
  let registrationTime: Date
  var status: RegistrationStatus
  let phone: String
  let email: String
  let reason: String  // 报名理由
  let attachments: [String]  // 附件链接
}

// 添加数据统计模型
struct StatisticItem: Identifiable {
  let id = UUID()
  let title: String
  let count: Int
  let trend: Double?  // 可选的趋势数据，正数表示上升，负数表示下降
}

// 修改统计卡片视图
struct StatisticCard: View {
  let item: StatisticItem

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(item.title)
        .font(.system(size: 13))
        .foregroundColor(Color(hex: "#999999"))

      HStack(alignment: .bottom, spacing: 8) {
        Text("\(item.count)")
          .font(.system(size: 22, weight: .medium))
          .foregroundColor(Color(hex: "#333333"))

        if let trend = item.trend {
          HStack(spacing: 2) {
            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
              .font(.system(size: 10))
            Text("\(abs(trend), specifier: "%.1f")%")
              .font(.system(size: 11))
          }
          .foregroundColor(trend >= 0 ? Color(.systemGreen) : Color(.systemRed))
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
    )
  }
}

struct RegistrationView: View {
  @EnvironmentObject var router: Router
  @State private var registrationUsers: [RegistrationUser] = [
    RegistrationUser(
      username: "张三",
      registrationTime: Date(),
      status: .pending,
      phone: "13800138000",
      email: "zhangsan@example.com",
      reason: "我对这个活动非常感兴趣，希望能够参与其中...",
      attachments: ["resume.pdf", "portfolio.pdf"]
    ),
    RegistrationUser(
      username: "李四",
      registrationTime: Date(),
      status: .pending,
      phone: "13800138000",
      email: "zhangsan@example.com",
      reason: "我对这个活动非常感兴趣，希望能够参与其中...",
      attachments: ["resume.pdf", "portfolio.pdf"]
    ),
    RegistrationUser(
      username: "王五",
      registrationTime: Date(),
      status: .registered,
      phone: "13800138000",
      email: "zhangsan@example.com",
      reason: "我对这个活动非常感兴趣，希望能够参与其中...",
      attachments: ["resume.pdf", "portfolio.pdf"]
    ),
    RegistrationUser(
      username: "赵六",
      registrationTime: Date(),
      status: .completed,
      phone: "13800138000",
      email: "zhangsan@example.com",
      reason: "我对这个活动非常感兴趣，希望能够参与其中...",
      attachments: ["resume.pdf", "portfolio.pdf"]
    ),
    RegistrationUser(
      username: "钱七",
      registrationTime: Date(),
      status: .rejected,
      phone: "13800138000",
      email: "zhangsan@example.com",
      reason: "我对这个活动非常感兴趣，希望能够参与其中...",
      attachments: ["resume.pdf", "portfolio.pdf"]
    ),
  ]
  let active: ActiveInfo

  // 统计数据
  private var statisticItems: [StatisticItem] {
    [
      StatisticItem(
        title: "总报名人数",
        count: registrationUsers.count,
        trend: 12.5
      ),
      StatisticItem(
        title: "待审核",
        count: registrationUsers.filter { $0.status == .pending }.count,
        trend: -5.2
      ),
      StatisticItem(
        title: "审核通过",
        count: registrationUsers.filter { $0.status == .completed }.count,
        trend: 8.3
      ),
      StatisticItem(
        title: "已驳回",
        count: registrationUsers.filter { $0.status == .rejected }.count,
        trend: nil
      ),
    ]
  }

  // 按状态分组的用户列表
  private var groupedUsers: [(String, [RegistrationUser])] {
    let grouped = Dictionary(grouping: registrationUsers) { $0.status }

    // 定义状态显示顺序
    let orderPriority: [RegistrationStatus] = [.pending, .registered, .completed, .rejected]

    return orderPriority.compactMap { status in
      if let users = grouped[status] {
        return (status.rawValue, users)
      }
      return nil
    }
  }

  var body: some View {
    VStack(spacing: 20) {
      // 统计卡片网格
      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: 12),
          GridItem(.flexible(), spacing: 12),
        ],
        spacing: 12
      ) {
        ForEach(statisticItems) { item in
          StatisticCard(item: item)
        }
      }
      .padding(.horizontal)
      .padding(.top)

      List {
        ForEach(groupedUsers, id: \.0) { section in
          Section(
            header:
              Text(section.0)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.gray)
              .padding(.top, 8)
          ) {
            ForEach(section.1) { user in
              RegistrationUserRow(user: user, active: active)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
          }
        }
      }
      .listStyle(.plain)
    }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("报名管理")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: {
          router.back()
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
            }
          }
          .foregroundStyle(Color(hex: "#333333"))
        })
    )
  }
}

// 用户行视图
struct RegistrationUserRow: View {
  let user: RegistrationUser
  let active: ActiveInfo
  @EnvironmentObject var router: Router

  var body: some View {
    HStack(spacing: 12) {
      // 用户头像
      Circle()
        .fill(Color(.systemGray5))
        .frame(width: 40, height: 40)
        .overlay(
          Text(String(user.username.prefix(1)))
            .foregroundColor(.gray)
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(user.username)
          .font(.system(size: 16, weight: .medium))
        Text(user.registrationTime.formatted())
          .font(.system(size: 13))
          .foregroundColor(.gray)
      }

      Spacer()

      Text(user.status.rawValue)
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(user.status.textColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(user.status.statusColor)
        .cornerRadius(6)
    }
    .padding(.vertical, 8)
    .onTapGesture {
      router.navigate(to: .submitActiveReview(active: active, mode: .review))
    }
  }
}

// 信息行组件 - 基础版本
struct InfoRow: View {
  let title: String
  let content: String

  var body: some View {
    HStack {
      Text(title)
        .font(.system(size: 14))
        .foregroundColor(Color(hex: "#999999"))

      Spacer()

      Text(content)
        .font(.system(size: 14))
        .foregroundColor(Color(hex: "#333333"))
    }
  }
}

// 信息行组件 - 自定义内容版本
struct InfoRowCustom<Content: View>: View {
  let title: String
  let content: () -> Content

  init(title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }

  var body: some View {
    HStack {
      Text(title)
        .font(.system(size: 14))
        .foregroundColor(Color(hex: "#999999"))

      Spacer()

      content()
    }
  }
}

//#Preview {
//  NavigationView {
//    RegistrationView()
//      .environmentObject(Router())
//  }
//}
