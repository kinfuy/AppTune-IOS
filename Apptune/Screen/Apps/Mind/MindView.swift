//
//  MindView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/2/23.
//

import SwiftUI

struct MindView: View {
  @EnvironmentObject var router: Router
  @StateObject private var viewModel: MindViewModel
  @FocusState private var isFocused: Bool

  init(activeRoles: Set<AgentRole>) {
    _viewModel = StateObject(wrappedValue: MindViewModel(activeRoles: activeRoles))
  }

  var body: some View {
    VStack(spacing: 0) {
      GroupChatView(viewModel: viewModel)
    }
    .customNavigationBar(
      title: "AI 头脑风暴",
      router: router,
      trailingItem: {
        Button(action: {
          viewModel.resetChat()
        }) {
          Image(systemName: "arrow.clockwise")
        }
      })
  }
}

#Preview {
  NavigationStack {
    MindView(activeRoles: [])
      .environmentObject(Router())
  }
}
