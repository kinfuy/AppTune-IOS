import SwiftUI

struct MessageBubble: View {
  let message: ChatMessage
  var onCopy: () -> Void = {}
  var onEdit: () -> Void = {}
  var onDelete: () -> Void = {}

  var body: some View {
    VStack(alignment: message.role.isUser ? .trailing : .leading, spacing: 4) {
      // 消息内容
      HStack(alignment: .top, spacing: 12) {
        if !message.role.isUser {
            Avatar(role: message.role)
        }

        VStack(alignment: message.role.isUser ? .trailing : .leading, spacing: 4) {
          if !message.role.isUser {
              Text(message.role.name)
              .font(.caption)
              .foregroundColor(.gray)
          }

          Text(message.content)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(
                    message.role.isUser
                    ? Color.blue
                    : Color(.systemBackground)
                )
            )
            .foregroundColor(message.role.isUser ? .white : .primary)
        }
        .frame(
          maxWidth: UIScreen.main.bounds.width * 0.7,
          alignment: message.role.isUser ? .trailing : .leading)

        if message.role.isUser {
          Avatar(role: message.role)
        } else {
          Spacer()
        }
      }

      // 消息工具栏
      MessageToolbar(
        isUserMessage: message.role.isUser,
        onCopy: onCopy,
        onEdit: onEdit,
        onDelete: onDelete
      )
    }
    .padding(.horizontal)
    .padding(.vertical, 4)
  }
}

// 消息工具栏
private struct MessageToolbar: View {
  let isUserMessage: Bool
  let onCopy: () -> Void
  let onEdit: () -> Void
  let onDelete: () -> Void

  @State private var isExpanded = false

  var body: some View {
    HStack(spacing: 16) {
      if !isUserMessage {
        ChatToolbarButton(
          icon: isExpanded ? "chevron.down" : "ellipsis",
          color: .gray
        ) {
          withAnimation(.spring(response: 0.3)) {
            isExpanded.toggle()
          }
        }
      }

      if isExpanded {
        Group {
          ChatToolbarButton(icon: "doc.on.doc", action: onCopy)
          if isUserMessage {
            ChatToolbarButton(icon: "pencil", action: onEdit)
            ChatToolbarButton(icon: "trash", color: .red, action: onDelete)
          }
        }
        .transition(.scale.combined(with: .opacity))
      }

      if isUserMessage {
        ChatToolbarButton(
          icon: isExpanded ? "chevron.down" : "ellipsis",
          color: .gray
        ) {
          withAnimation(.spring(response: 0.3)) {
            isExpanded.toggle()
          }
        }
      }
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
  let role: AgentRole

  var body: some View {
    ZStack {
      Image(systemName: role.icon)
        .font(.system(size: 16))
        .foregroundColor(.white)
        .frame(width: 32, height: 32)
        .background(
          Circle()
            .fill(role.backgroundColor)
            .shadow(color: role.backgroundColor.opacity(0.3), radius: 4, y: 2)
        )

      if role.isModerator {
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
          id: UUID(),
          role: AgentRole.user(),
          content: "这是用户发送的消息",
          timestamp: Date()
        )
      )

      MessageBubble(
        message: ChatMessage(
          id: UUID(),
          role: AgentRole(id: UUID(), name: "用户", isSelectable: false, isModerator: false, icon: "user", description: "用户", isCustom: false, backgroundColor: .gray, isUser: false,configuration: nil,prompts: nil),
          content: "这是AI助手的回复消息",
          timestamp: Date()
        )
      )
    }
    .padding()
  }
}
