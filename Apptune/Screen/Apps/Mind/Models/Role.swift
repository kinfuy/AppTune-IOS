import SwiftUI

enum RoleType {
  case system
  case agent
}

struct RoleConfiguration {
  let temperature: Double
  let maxTokens: Int
  let topP: Double
}

struct RolePrompt {
  let systemPrompt: String
  let userPrompt: String
}

struct AgentRole: Identifiable, Hashable, Equatable {
  static func == (lhs: AgentRole, rhs: AgentRole) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  let id: UUID
  let name: String
  let isSelectable: Bool  // 是否可选
  let isModerator: Bool  // 是否是主持人
  let icon: String
  let description: String
  let isCustom: Bool
  let backgroundColor: Color
  let isUser: Bool
  let configuration: RoleConfiguration?
  let prompts: RolePrompt?

  static var user = {
    AgentRole(
      id: UUID(),
      name: "用户",
      isSelectable: false,
      isModerator: false,
      icon: "person.fill",
      description: "用户",
      isCustom: false,
      backgroundColor: .blue,
      isUser: true,
      configuration: nil,
      prompts: nil
    )
  }
}

class RoleManager {
  static let shared = RoleManager()
  private(set) var moderator: AgentRole?
  private(set) var roles: [AgentRole] = []

  func setModerator(_ role: AgentRole?) {
    moderator = role
  }

  func addRole(_ role: AgentRole) {
    roles.append(role)
  }

  func removeRole(_ role: AgentRole) {
    roles.removeAll { $0.id == role.id }
  }
}

// 角色组合
struct RoleGroup: Hashable {
  let id: UUID
  let name: String
  let description: String
  let roles: [AgentRole]
  let icon: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: RoleGroup, rhs: RoleGroup) -> Bool {
    lhs.id == rhs.id
  }
}
