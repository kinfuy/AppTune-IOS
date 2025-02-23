import SwiftUI

struct GroupChatView: View {
  @ObservedObject var viewModel: MindViewModel
  @FocusState var isFocused: Bool

  var body: some View {
    VStack(spacing: 0) {
      // 添加角色状态栏
      RoleStatusBar(
        activeRoles: viewModel.activeRoles,
        typingRole: viewModel.typingRole
      )

      Divider()

      // 聊天记录
      ChatHistoryView(
        messages: viewModel.messages,
        activeRoles: viewModel.activeRoles,
        onMessageDelete: { message in
          if let index = viewModel.messages.firstIndex(where: { $0.id == message.id }) {
            viewModel.messages.remove(at: index)
          }
        }
      )

      // 底部输入区域
      InputArea(
        text: $viewModel.messageText,
        isTyping: viewModel.isAITyping,
        isFocused: _isFocused,
        onSend: sendMessage,
        onInterrupt: viewModel.interruptConversation,
        onNewChat: viewModel.startNewConversation
      )
    }
  }

  @MainActor
  private func sendMessage() {
    guard !viewModel.messageText.isEmpty else { return }
    let message = ChatMessage(
      role: .user,
      content: viewModel.messageText,
      timestamp: Date()
    )
    viewModel.messages.append(message)
    viewModel.messageText = ""

    // TODO: 触发AI响应
    simulateAIResponse()
  }

  @MainActor
  private func simulateAIResponse() {
    viewModel.isAITyping = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let aiRoles = Array(viewModel.activeRoles.filter { $0 != .user })
      guard let aiRole = aiRoles.randomElement() else { return }

      let aiMessage = ChatMessage(
        role: aiRole,
        content: "这是来自\(aiRole.rawValue)的回复",
        timestamp: Date()
      )
      viewModel.messages.append(aiMessage)
      viewModel.isAITyping = false
    }
  }
}

// 聊天记录视图
private struct ChatHistoryView: View {
  let messages: [ChatMessage]
  let activeRoles: Set<ProductRole>
  let onMessageDelete: (ChatMessage) -> Void

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 8) {
          if messages.isEmpty {
            EmptyStateView(activeRoles: activeRoles)
          }

          ForEach(messages) { message in
            MessageBubble(
              message: message,
              onCopy: {
                UIPasteboard.general.string = message.content
              },
              onEdit: {
                // TODO: 实现编辑功能
              },
              onDelete: {
                onMessageDelete(message)
              }
            )
          }
        }
        .padding(.vertical)
      }
      .onChange(of: messages.count) { _ in
        withAnimation(.easeOut(duration: 0.3)) {
          proxy.scrollTo(messages.last?.id, anchor: .bottom)
        }
      }
    }
    .background(Color(.systemGroupedBackground))
  }
}

// 空状态视图
private struct EmptyStateView: View {
  let activeRoles: Set<ProductRole>

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "bubble.left.and.bubble.right.fill")
        .font(.system(size: 40))
        .foregroundColor(.blue.opacity(0.3))

      VStack(spacing: 8) {
        Text("开始群组讨论")
          .font(.headline)

        // 显示每个AI角色
        ForEach(
          Array(activeRoles).filter({ $0 != .user }).sorted(by: { $0.rawValue < $1.rawValue }),
          id: \.self
        ) { role in
          Text("\(role.rawValue)已加入讨论")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}
