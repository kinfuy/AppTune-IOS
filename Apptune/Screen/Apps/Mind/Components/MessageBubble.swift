import MarkdownUI
import SwiftUI

struct MessageBubble: View {
  let message: ChatMessage
  var onCopy: () -> Void = {}

  @ViewBuilder
  private func messageContent() -> some View {
    if message.isUserMessage {
      Text(message.content)
        .color(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.primary)
        .cornerRadius(all: 8)
        .textSelection(.enabled)
    } else {
      if message.typingState == .loading {
        LoadingComponent(color: .gray, size: 12)
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
      } else {
        Markdown(message.content)
          .markdownTheme(.gitHub)
          .padding(12)
          .background(.white)
          .cornerRadius(all: 8)
          .textSelection(.enabled)
      }
    }
  }

  var body: some View {
    VStack(alignment: message.isUserMessage ? .trailing : .leading, spacing: 4) {
      HStack(alignment: .top, spacing: 12) {
        if !message.isUserMessage {
          Avatar(agent: message.agent!)
        }

        VStack(alignment: message.isUserMessage ? .trailing : .leading, spacing: 4) {
          if !message.isUserMessage {
            Text(message.agent!.name)
              .font(.caption)
              .foregroundColor(.gray)
          }

          messageContent()
            .padding(.vertical, 12)
        }
        .frame(
          maxWidth: UIScreen.main.bounds.width * 0.75,
          alignment: message.isUserMessage ? .trailing : .leading
        )

        if message.isUserMessage {
          ImgLoader("p_1")
            .cornerRadius(all: 8)
            .frame(width: 32, height: 32)
        } else {
          Spacer()
        }
      }
      if !message.isUserMessage && message.typingState == .done {
        MessageToolbar(
          isUserMessage: message.isUserMessage,
          onCopy: onCopy
        )
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 4)
  }
}

// 消息工具栏
private struct MessageToolbar: View {
  let isUserMessage: Bool
  let onCopy: () -> Void

  var body: some View {
    HStack(spacing: 16) {
      Group {
        ChatToolbarButton(icon: "doc.on.doc", action: onCopy)
      }
      .transition(.scale.combined(with: .opacity))
    }
    .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
    .padding(.horizontal, isUserMessage ? 52 : 44)
    .padding(.top, 2)
  }
}

private struct ChatToolbarButton: View {
  let icon: String
  var color: Color = .blue
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(color)
        .frame(width: 24, height: 24)
        .background(
          Circle()
            .fill(color.opacity(0.1))
        )
    }
  }
}

private struct Avatar: View {
  let agent: Agent

  var body: some View {
    ZStack {
      ImgLoader(agent.avatar)
        .cornerRadius(all: 8)
        .frame(width: 32, height: 32)
      if agent.isModerator {
        Image(systemName: "star.fill")
          .font(.system(size: 10))
          .foregroundColor(.yellow)
          .offset(x: 12, y: -12)
      }
    }
  }
}

struct MessageBubble_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 20) {
      MessageBubble(
        message: ChatMessage(
          role: .user,
          content: "这是用户发送的消息",
          timestamp: Date()
        )
      )

      MessageBubble(
        message: ChatMessage(
          role: .assistant,
          content: "#### 这是AI助手的回复消息\n ss",
          timestamp: Date(),
          agent: Agent(
            id: UUID().uuidString, userId: "1", name: "AI", description: "SS", avatar: "p_3",
            isPublic: true, status: 1, isModerator: false, isCustom: true,
            configuration: AgentConfiguration(temperature: 0.7, maxTokens: 1000, topP: 1),
            prompts: AgentPrompt(systemPrompt: "ce", userPrompt: "ss"), type: "ss",
            createTime: Date(), updateTime: Date())
        )
      )
    }
    .padding()
  }
}

struct MessageBubble_Loading_Previews: PreviewProvider {
  static var previews: some View {
    MessageBubble(
      message: ChatMessage(
        role: .assistant,
        content: "",
        timestamp: Date(),
        agent: Agent(
          id: UUID().uuidString,
          userId: "1",
          name: "AI",
          description: "SS",
          avatar: "p_3",
          isPublic: true,
          status: 1,
          isModerator: false,
          isCustom: true,
          configuration: AgentConfiguration(temperature: 0.7, maxTokens: 1000, topP: 1),
          prompts: AgentPrompt(systemPrompt: "ce", userPrompt: "ss"),
          type: "ss",
          createTime: Date(),
          updateTime: Date()
        ),
        typingState: .loading
      )
    )
    .padding()
  }
}
