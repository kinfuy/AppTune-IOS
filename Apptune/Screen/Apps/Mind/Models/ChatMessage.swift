import Foundation

enum ChatMessageRole: String, Codable {
  case user
  case assistant
  case system
}

enum ChatWriteState: Int, Codable {
  case loading
  case typing
  case done
}

struct ChatMessage: Identifiable, Equatable {
  static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
    return lhs.id == rhs.id && lhs.content == rhs.content
      && lhs.timestamp == rhs.timestamp
  }

  let id = UUID()
  let agent: Agent?
  var content: String
  let timestamp: Date
  let role: ChatMessageRole
  var typingState: ChatWriteState

  var isUserMessage: Bool {
    return role == .user
  }

  var isCode: Bool {
    content.hasPrefix("```") && content.hasSuffix("```")
  }

  init(
    role: ChatMessageRole, 
    content: String,
    timestamp: Date,
    agent: Agent? = nil,
    typingState: ChatWriteState = .done
  ) {
    self.content = content
    self.timestamp = timestamp
    self.role = role
    self.agent = agent
    self.typingState = typingState
  }
}
