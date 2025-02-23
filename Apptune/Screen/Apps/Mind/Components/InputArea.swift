import SwiftUI

struct InputArea: View {
  @Binding var text: String
  let isTyping: Bool
  @FocusState var isFocused: Bool
  let onSend: () -> Void
  let onInterrupt: () -> Void
  let onNewChat: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      // 工具栏
      ChatToolbar(
        onInterrupt: onInterrupt,
        onNewChat: onNewChat,
        isHidden: !text.isEmpty
      )

      // 输入区域
      HStack(spacing: 12) {
        InputField(
          text: $text,
          isTyping: isTyping,
          isFocused: _isFocused
        )

        SendButton(
          isEnabled: !text.isEmpty && !isTyping,
          action: onSend
        )
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(.systemBackground))
      .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
    }
  }
}

// 输入框组件
private struct InputField: View {
  @Binding var text: String
  let isTyping: Bool
  @FocusState var isFocused: Bool

  var body: some View {
    ZStack(alignment: .leading) {
      if text.isEmpty {
        Text("发送消息...")
          .foregroundColor(.gray.opacity(0.8))
          .padding(.leading, 16)
      }

      TextField("", text: $text)
        .textFieldStyle(.plain)
        .padding(.horizontal, 16)
        .focused($isFocused)
        .disabled(isTyping)
    }
    .frame(height: 36)
    .background(
      RoundedRectangle(cornerRadius: 18)
        .fill(Color(.systemGray6))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .stroke(Color(.systemGray4), lineWidth: 0.5)
    )
  }
}

// 发送按钮组件
private struct SendButton: View {
  let isEnabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "paperplane.fill")
        .font(.system(size: 16, weight: .semibold))
        .frame(width: 36, height: 36)
        .foregroundColor(.white)
        .background(
          Circle()
            .fill(
              isEnabled
                ? LinearGradient(
                  colors: [.blue, .blue.opacity(0.8)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
                : LinearGradient(
                  colors: [Color(.systemGray4), Color(.systemGray3)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
            )
            .shadow(
              color: isEnabled ? .blue.opacity(0.3) : .clear,
              radius: 8,
              y: 4
            )
        )
    }
    .disabled(!isEnabled)
    .animation(.easeInOut(duration: 0.2), value: isEnabled)
  }
}
