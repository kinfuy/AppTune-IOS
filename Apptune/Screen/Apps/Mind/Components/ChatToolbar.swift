import SwiftUI

struct ChatToolbar: View {
  let onInterrupt: () -> Void
  let onNewChat: () -> Void
  let isHidden: Bool

  var body: some View {
    HStack(spacing: 0) {
      Spacer()
      ToolButton(
        title: "打断",
        icon: "hand.raised",
        color: .orange,
        isHidden: isHidden
      ) {
        onInterrupt()
      }

      ToolButton(
        title: "新对话",
        icon: "plus",
        color: .blue
      ) {
        onNewChat()
      }
    }
    .padding(.horizontal)
  }
}

private struct ToolButton: View {
  let title: String
  let icon: String
  let color: Color
  var isHidden: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 12, weight: .medium))
        Text(title)
          .font(.system(size: 12, weight: .medium))
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(
        Capsule()
          .fill(color.opacity(0.15))
      )
      .foregroundColor(color)
    }
    .padding(.leading, 8)
    .opacity(isHidden ? 0 : 1)
    .animation(.easeInOut(duration: 0.2), value: isHidden)
  }
}
