import SwiftUI

struct GroupChatView: View {
  @ObservedObject var viewModel: MindViewModel
  @FocusState var isFocused: Bool

  var body: some View {
    VStack(spacing: 0) {
      // 添加角色状态栏

      Divider()

      // 聊天记录
      ChatHistoryView(
        messages: viewModel.messages,
        agents: viewModel.agents,
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
        onSend: viewModel.sendMessage,
        onInterrupt: viewModel.interruptConversation,
        onNewChat: viewModel.startNewConversation
      )
    }
  }
}

// 聊天记录视图
private struct ChatHistoryView: View {
  let messages: [ChatMessage]
  let agents: [Agent]
  let onMessageDelete: (ChatMessage) -> Void

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 8) {
          if messages.isEmpty {
            EmptyStateView(agents: agents)
          }

          ForEach(messages) { message in
            MessageBubble(
              message: message,
              onCopy: {
                UIPasteboard.general.string = message.content
              }
            )
          }

          // 添加一个不可见的锚点视图
          Color.clear
            .frame(height: 1)
            .id("bottom")
        }
        .padding(.vertical)
      }
      .onChange(of: messages) { _ in
        // 当消息数组发生变化时滚动到底部
        withAnimation(.easeOut(duration: 0.3)) {
          proxy.scrollTo("bottom", anchor: .bottom)
        }
      }
    }
    .background(Color(.systemGroupedBackground))
  }
}

// 空状态视图
private struct EmptyStateView: View {
  let agents: [Agent]

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "bubble.left.and.bubble.right.fill")
        .font(.system(size: 40))
        .foregroundColor(.blue.opacity(0.3))

      VStack(spacing: 8) {
        Text("开始群组讨论")
          .font(.headline)

        // 显示每个AI角色
        ForEach(agents.sorted(by: { $0.name < $1.name }), id: \.id) { agent in
          Text("\(agent.name)已加入讨论")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}
