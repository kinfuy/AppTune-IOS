import Foundation

struct ChatMessage: Identifiable, Equatable {
  static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
    return lhs.id == rhs.id && lhs.role == rhs.role && lhs.content == rhs.content
      && lhs.timestamp == rhs.timestamp
  }

  let id: UUID
  let role: AgentRole
  let content: String
  let timestamp: Date

  init(id: UUID = UUID(), role: AgentRole, content: String, timestamp: Date) {
    self.id = id
    self.role = role
    self.content = content
    self.timestamp = timestamp
  }
}
