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
    ZStack(alignment: .bottom) {
      VStack(spacing: 0) {
        // 搜索栏
        SearchBar(text: $viewModel.searchText)
          .padding()

        if viewModel.filteredGroups.isEmpty {
          if viewModel.isLoading {
            VStack {
              Spacer()
              LoadingComponent()
              Spacer()
            }
          } else {
            EmptyView()
          }
        }

        // 主列表
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredGroups, id: \.id) { group in
              GroupListItem(
                group: group,
                isSelected: viewModel.selectedGroup?.id == group.id
              ) {
                viewModel.selectGroup(group)
              }
            }
          }
          .padding(.horizontal)

          // 底部空间
          Spacer()
            .frame(height: 80)
        }
      }

      StartChatButton(viewModel: viewModel)
        .shadow(radius: 2)
    }
    .onAppear {
      Task {
        await viewModel.loadData()
      }
    }
    .customNavigationBar(
      title: "AI 头脑风暴",
      router: router,
      trailingItem: {
        Button(action: {
        }) {
          Text("自定义")
            .color(.primary)
        }
      }
    )
  }
}

// 搜索栏
private struct SearchBar: View {
  @Binding var text: String

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)

      TextField("搜索讨论组", text: $text)
        .textFieldStyle(PlainTextFieldStyle())

      if !text.isEmpty {
        Button(action: { text = "" }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(8)
    .background(Color(.systemGray6))
    .cornerRadius(10)
  }
}

// 讨论组列表项
private struct GroupListItem: View {
  let group: AgentGroup
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        // 头像组
        AvatarGroup(agents: group.agents)
          .frame(width: 60, height: 60)

        // 文字信息
        VStack(alignment: .leading, spacing: 4) {
          Text(group.name)
            .font(.headline)

          Text(group.description)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 16)
      .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// 头像组
private struct AvatarGroup: View {
  let agents: [Agent]

  var body: some View {
    ZStack {
      ForEach(Array(agents.prefix(2).enumerated()), id: \.element.id) { index, agent in
        ImgLoader(agent.avatar)
          .cornerRadius(all: 12)
          .frame(width: 52, height: 52)
          .offset(x: CGFloat(index) * 15)
      }
    }
  }
}

// 开始讨论按钮
private struct StartChatButton: View {
  @EnvironmentObject var router: Router
  @ObservedObject var viewModel: SelectChatViewModel

  private var isEnabled: Bool {
    viewModel.selectedGroup != nil
  }

  var body: some View {
    Button {
      if let group = viewModel.selectedGroup {
        router.navigate(to: .mindChat(agents: group.agents))
      }
    } label: {
      Text("开始头脑风暴")
        .buttonStyle(isEnabled ? .primary : .secondary)
        .frame(height: 48)
    }
    .disabled(!isEnabled)
    .padding(.horizontal)
    .padding(.bottom, 20)
  }
}

#Preview {
  NavigationStack {
    SelectChatView()
      .environmentObject(Router())
  }
  .preferredColorScheme(.light)
}
