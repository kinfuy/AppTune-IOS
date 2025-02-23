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
        VStack(spacing: 24) {
          Text("选择讨论组")
            .font(.title2)
            .bold()
            .padding(.top, 40)

          RecommendedGroupsSection(viewModel: viewModel)
          CustomRolesSection(viewModel: viewModel)

          // 添加底部空间，防止内容被按钮遮挡
          Spacer()
            .frame(height: 80)
        }
      }

      // 固定在底部的按钮
      if viewModel.customRoles.count >= 1 {
        StartChatButton(viewModel: viewModel)
          .shadow(radius: 2)  // 添加阴影效果提升层次感
      }
    }
    .customNavigationBar(
      title: "AI 头脑风暴",
      router: router
    )
  }
}

// 推荐组合部分
private struct RecommendedGroupsSection: View {
  @EnvironmentObject var router: Router
  @ObservedObject var viewModel: SelectChatViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("推荐组合")
        .font(.headline)
        .padding(.horizontal)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(ProductRole.recommendedGroups, id: \.self) { group in
            RecommendedGroupCard(
              roles: group.roles,
              isActive: false
            ) {
              let activeRoles = viewModel.getActiveRoles(from: group.roles)
              router.navigate(to: .mindChat(roles: activeRoles))
            }
          }
        }
        .padding(.horizontal)
      }
    }
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
        ForEach(ProductRole.selectableRoles) { role in
          AgentCard(
            role: role,
            isActive: viewModel.customRoles.contains(role)
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

  var body: some View {
    Button {
      let activeRoles = viewModel.getActiveRoles(from: Array(viewModel.customRoles))
      router.navigate(to: .mindChat(roles: activeRoles))
    } label: {
      Text("开始讨论 (\(viewModel.customRoles.count)个角色)")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
    .padding(.horizontal)
    .padding(.bottom, 20)  // 调整底部间距
  }
}

#Preview {
  NavigationStack {
    SelectChatView()
      .environmentObject(Router())
  }
}
