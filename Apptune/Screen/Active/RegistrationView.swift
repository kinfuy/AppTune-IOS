//
//  RegistrationView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/23.
//

import SwiftUI

// 定义报名状态枚举
enum RegistrationStatus: Int, Codable {
  case registered = 0
  case pending = 1
  case completed = 2
  case rejected = 3

  var label: String {
    switch self {
    case .registered: return "已报名"
    case .pending: return "待审核"
    case .rejected: return "已驳回"
    case .completed: return "已完成"
    }
  }

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
struct RegistrationUser: Codable {
  let userId: String
  let username: String
  let avatar: String
  let joinTime: Date
  var submissionStatus: RegistrationStatus?
  var submissionTime: Date?
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
  @EnvironmentObject var activeService: ActiveService

  @State private var registrationUsers: [RegistrationUser] = []
  @State private var refreshID = UUID()  // 添加刷新标识
  let active: ActiveInfo

  // 统计数据
  @State private var statisticItems: [StatisticItem] = []

  @MainActor
  private func loadStatisticItems() async {
    let stats = await activeService.getActiveRegistrationStats(activeId: active.id)
    statisticItems = [
      StatisticItem(
        title: "总报名人数",
        count: stats.totalJoins,
        trend: nil
      ),
      StatisticItem(
        title: "待审核",
        count: stats.pendingReviews,
        trend: nil
      ),
      StatisticItem(
        title: "审核通过",
        count: stats.approvedReviews,
        trend: nil
      ),
      StatisticItem(
        title: "已驳回",
        count: stats.rejectedReviews,
        trend: nil
      ),
    ]
  }

  @MainActor
  private func refreshData() async {
    let users = await activeService.getActiveRegistrationList(activeId: active.id)
    registrationUsers = users ?? []
    await loadStatisticItems()
    refreshID = UUID()  // 强制视图刷新
  }

  // 按状态分组的用户列表
  private var groupedUsers: [(String, [RegistrationUser])] {
    let grouped = Dictionary(grouping: registrationUsers) { $0.submissionStatus }

    // 定义状态显示顺序
    let orderPriority: [RegistrationStatus] = [.pending, .registered, .completed, .rejected]

    return orderPriority.compactMap { status in
      if let users = grouped[status] {
        return (status.label, users)
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
            ForEach(section.1, id: \.userId) { user in
              RegistrationUserRow(
                user: user, active: active,
                onRefresh: {
                  Task { @MainActor in
                    await refreshData()
                  }
                }
              )
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
            }
          }
        }
      }
      .listStyle(.plain)
    }
    .id(refreshID)  // 添加刷新标识
    .onAppear {
      Task { @MainActor in
        await refreshData()
      }
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
  let onRefresh: () -> Void
  @EnvironmentObject var router: Router
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var activeService: ActiveService

  // 提交审核结果
  private func submitAuditResult(extra: SubmitExtraParams? = nil) async {
    await activeService.submitAuditResult(
      activeId: active.id,
      userId: user.userId,
      status: .approved,
      reason: "",
      extra: extra,
      success: {
        notice.open(open: .toast("奖励发放成功"))
        // 刷新列表
        onRefresh()
      }
    )
  }

  @MainActor
  private func confirmReward(desc: String?, extra: SubmitExtraParams? = nil) async {
    notice.open(
      open: .confirm(
        title: "确定发放奖励吗？",
        desc: desc ?? "",
        onSuccess: {
          Task {
            await submitAuditResult(extra: extra)

          }
        }))
  }

  @MainActor
  private func checkRewardValidity() async {
    if active.rewardType == .promoCode {
      // rewardPromoCodes 多个需要用户选择
      if active.rewardPromoCodes?.count ?? 0 > 1 {
        sheet.show(
          .preCodePicker(
            productId: active.productId,
            selectedGroups: [],
            onSelect: { groups in
              Task {
                let group = groups[0]
                let desc = "审核通过将奖励用户\(group)优惠码"
                await confirmReward(
                  desc: desc, extra: SubmitExtraParams(userId: user.userId, group: group))
              }
            },
            onCancel: nil,
            config: ProCodeSheetConfig(allowMultipleSelection: true, title: "绑定优惠码分组")))
      } else {
        await confirmReward(
          desc: "审核通过将奖励用户 \(active.rewardPromoCodes?.first ?? "") 优惠码",
          extra: SubmitExtraParams(userId: user.userId, group: active.rewardPromoCodes?.first ?? "")
        )
      }
    }

    if active.rewardType == .points {
      if let points = active.rewardPoints {
        await confirmReward(desc: "审核通过将奖励用户 \(points.description) 积分")
      } else {
        await confirmReward(desc: "审核通过将奖励用户")
      }
    }
    if active.rewardType == .selfManaged {
      await confirmReward(desc: "确认奖励已经发放？")
    }
  }

  var body: some View {
    HStack(spacing: 12) {
      // 用户头像
      ImgLoader(user.avatar)
        .frame(width: 44, height: 44)
        .cornerRadius(all: 22)

      VStack(alignment: .leading, spacing: 4) {
        Text(user.username)
          .font(.system(size: 15, weight: .medium))

        HStack(spacing: 8) {
          if let status = user.submissionStatus {
            Text(status.label)
              .font(.system(size: 12))
              .foregroundColor(status.textColor)
          }

          Text("•")
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "#999999"))

          Text(user.joinTime.formatted())
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "#999999"))
        }
      }

      Spacer()

      // 非报名状态显示查看按钮
      if let status = user.submissionStatus, status != .registered {
        Button(action: {
          router.navigate(
            to: .submitActiveReview(active: active, mode: .review, userId: user.userId))
        }) {
          Text("查看")
            .font(.system(size: 14))
            .foregroundColor(Color(.systemBlue))
        }
      } else if active.auditType == .noAudit {
        Button(action: {
          Task {
            Tap.shared.play(.light)
            await checkRewardValidity()
          }
        }) {
          Text("奖励发放")
            .font(.system(size: 14))
            .foregroundColor(Color(.systemBlue))
        }
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
    )
    .padding(.vertical, 4)
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

// #Preview {
//  NavigationView {
//    RegistrationView()
//      .environmentObject(Router())
//  }
// }
