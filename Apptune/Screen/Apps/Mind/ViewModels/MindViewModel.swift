import Foundation
import SwiftUI

class MindViewModel: ObservableObject {
  @Published var messageText = ""
  @Published var messages: [ChatMessage] = []
  @Published var activeRoles: Set<ProductRole>
  @Published var isAITyping = false
  @Published var typingRole: ProductRole? = nil

  init(activeRoles: Set<ProductRole>) {
    self.activeRoles = activeRoles
  }

  func resetChat() {
    messages.removeAll()
    messageText = ""
  }

  func interruptConversation() {
    isAITyping = false
    // TODO: 实现打断逻辑
  }

  func startNewConversation() {
    messages.removeAll()
    messageText = ""
  }

  @MainActor
  private func simulateAIResponse() {
    let aiRoles = Array(activeRoles.filter { $0 != .user })
    guard let aiRole = aiRoles.randomElement() else { return }

    isAITyping = true

    // 在主线程上更新状态并添加动画
    DispatchQueue.main.async {
      withAnimation(.spring(duration: 0.5)) {
        self.typingRole = aiRole
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      let aiMessage = ChatMessage(
        role: aiRole,
        content: "这是来自\(aiRole.rawValue)的回复",
        timestamp: Date()
      )

      withAnimation(.spring(duration: 0.5)) {
        self.messages.append(aiMessage)
        self.isAITyping = false
        self.typingRole = nil
      }
    }
  }
}
