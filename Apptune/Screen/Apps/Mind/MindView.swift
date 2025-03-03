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

  init(agents: [Agent]) {
    _viewModel = StateObject(wrappedValue: MindViewModel(agents: agents))
  }

  var body: some View {
    VStack(spacing: 0) {
      GroupChatView(viewModel: viewModel)
    }
    .customNavigationBar(
      title: "头脑风暴",
      router: router,
      trailingItem: {
        Button(action: {
          // 聊天设置
        }) {
          Image(systemName: "gear")
        }
      })
  }
}

#Preview {
  NavigationStack {
    MindView(agents: [])
      .environmentObject(Router())
  }
}
