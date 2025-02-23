import Foundation
import SwiftUI

@MainActor
class MindViewModel: ObservableObject {
  @Published var messageText = ""
  @Published var messages: [ChatMessage] = []
  @Published var activeRoles: Set<AgentRole>
  @Published var isAITyping = false
  @Published var typingRole: AgentRole? = nil

  init(activeRoles: Set<AgentRole>) {
    self.activeRoles = activeRoles
    print("🎮 MindViewModel - Initialized with roles: \(activeRoles.map(\.name))")
  }

  func resetChat() {
    messages.removeAll()
    messageText = ""
  }

  func interruptConversation() {
    print("⚠️ Chat - Conversation interrupted")
    isAITyping = false
    typingRole = nil
  }

  func startNewConversation() {
    print("🔄 Chat - Starting new conversation")
    messages.removeAll()
    messageText = ""
  }

  func sendMessage() {
    guard !messageText.isEmpty else { return }

    let userMessage = ChatMessage(
      role: AgentRole.user(),
      content: messageText,
      timestamp: Date()
    )

    withAnimation {
      messages.append(userMessage)
      messageText = ""
    }

    simulateAIResponse()
  }

  private func simulateAIResponse() {
    let aiRoles = Array(activeRoles)
    guard let aiRole = aiRoles.randomElement() else { return }

    isAITyping = true
    withAnimation(.spring(duration: 0.5)) {
      print("💭 Chat - \(aiRole.name) is typing...")
      self.typingRole = aiRole
    }

    Task { @MainActor in
      try? await Task.sleep(for: .seconds(3))

      let aiMessage = ChatMessage(
        role: aiRole,
        content: "这是来自\(aiRole.name)的回复",
        timestamp: Date()
      )

      withAnimation(.spring(duration: 0.5)) {
        self.messages.append(aiMessage)
        self.isAITyping = false
        print("💬 Chat - \(aiRole.name) responded")
        self.typingRole = nil
      }
    }
  }
}
