//
//  SelectChatView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/2/23.
//

import SwiftUI

struct SelectChatView: View {
  @EnvironmentObject var router: Router
  @StateObject private var viewModel = SelectChatViewModel()

  var body: some View {
    // 使用 ZStack 来叠加固定按钮
    ZStack(alignment: .bottom) {
      // 主要内容使用 ScrollView
      ScrollView {
        VStack(spacing: 16) {
          // 添加推荐讨论组部分
          RecommendedGroupsSection(viewModel: viewModel)

          CustomRolesSection(viewModel: viewModel)

          // 添加底部空间，防止内容被按钮遮挡
          Spacer()
            .frame(height: 80)
        }
        .padding(.top)
      }

      StartChatButton(viewModel: viewModel)
        .shadow(radius: 2)  // 添加阴影效果提升层次感
    }
    .customNavigationBar(
      title: "AI 头脑风暴",
      router: router
    )
  }
}

// 角色标签视图
private struct RoleTag: View {
  let role: AgentRole

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: role.icon)
        .font(.caption)
      Text(role.name)
        .font(.caption)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(role.backgroundColor.opacity(0.1))
    .foregroundColor(role.backgroundColor)
    .cornerRadius(8)
  }
}

// 自定义角色部分
private struct CustomRolesSection: View {
  @ObservedObject var viewModel: SelectChatViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("自定义角色")
        .font(.headline)
        .padding(.horizontal)

      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
        spacing: 16
      ) {
        ForEach(AgentRole.defaultRoles.filter { $0.isSelectable }, id: \.id) { role in
          AgentCard(
            role: role,
            isActive: viewModel.customRoles.contains(where: { $0.id == role.id }),
            isModerator: role.id == viewModel.moderator?.id
          ) {
            viewModel.toggleCustomRole(role)
          }
        }
      }
      .padding(.horizontal)
    }
  }
}

// 开始讨论按钮
private struct StartChatButton: View {
  @EnvironmentObject var router: Router
  @ObservedObject var viewModel: SelectChatViewModel

  private var buttonText: String {
    if viewModel.selectedGroup != nil {
      return "开始群组讨论"
    } else {
      return "开始讨论 (\(viewModel.customRoles.count)个角色)"
    }
  }

  private var isEnabled: Bool {
    viewModel.selectedGroup != nil || viewModel.customRoles.count >= 1
  }

  var body: some View {
    Button {
      let roles =
        if let group = viewModel.selectedGroup {
          Set(group.roles)
        } else {
          viewModel.customRoles
        }
      router.navigate(to: .mindChat(roles: roles))
    } label: {
      Text(buttonText)
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(isEnabled ? Color.blue : Color.gray)
        .cornerRadius(12)
    }
    .disabled(!isEnabled)
    .padding(.horizontal)
    .padding(.bottom, 20)
  }
}

// 添加推荐讨论组部分
private struct RecommendedGroupsSection: View {
  @ObservedObject var viewModel: SelectChatViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("推荐讨论组")
        .font(.headline)
        .padding(.horizontal)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(RoleGroup.recommendedGroups, id: \.id) { group in
            RecommendedGroupCard(
              group: group,
              isActive: viewModel.selectedGroup?.id == group.id
            ) {
              viewModel.selectGroup(group)
            }
          }
        }
        .padding(.horizontal)
      }
    }
  }
}

#Preview {
  NavigationStack {
    SelectChatView()
      .environmentObject(Router())
  }
  .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
  NavigationStack {
    SelectChatView()
      .environmentObject(Router())
  }
  .preferredColorScheme(.dark)
}
