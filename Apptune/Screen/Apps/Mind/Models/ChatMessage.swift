import Foundation

struct ChatMessage: Identifiable {
  let id: UUID
  let role: ProductRole
  let content: String
  let timestamp: Date

  init(id: UUID = UUID(), role: ProductRole, content: String, timestamp: Date) {
    self.id = id
    self.role = role
    self.content = content
    self.timestamp = timestamp
  }
}
