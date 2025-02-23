import SwiftUI

extension RoleGroup {
  static let recommendedGroups: [RoleGroup] = [
    RoleGroup(
      id: UUID(),
      name: "产品设计组",
      description: "产品经理和设计师的完美组合，专注于产品创新和用户体验",
      roles: [
        AgentRole.defaultRoles[0],  // 产品经理
        AgentRole.defaultRoles[1],  // 设计师
      ],
      icon: "lightbulb.fill"
    ),
    RoleGroup(
      id: UUID(),
      name: "全能开发组",
      description: "产品、设计、开发的黄金组合，让想法快速落地",
      roles: [
        AgentRole.defaultRoles[0],  // 产品经理
        AgentRole.defaultRoles[1],  // 设计师
        AgentRole.defaultRoles[2],  // 开发工程师
      ],
      icon: "gear.fill"
    ),
    RoleGroup(
      id: UUID(),
      name: "技术评审组",
      description: "多个开发工程师组成的技术评审小组，深入讨论技术方案",
      roles: [
        AgentRole.defaultRoles[2],  // 开发工程师
        AgentRole.defaultRoles[2],  // 开发工程师
      ],
      icon: "hammer.fill"
    ),
  ]
}

extension AgentRole {
  static let defaultRoles: [AgentRole] = [
    AgentRole(
      id: UUID(),
      name: "产品经理",
      isSelectable: true,
      isModerator: true,
      icon: "briefcase.fill",
      description: "产品经理角色",
      isCustom: false,
      backgroundColor: .green,
      isUser: false,
      configuration: RoleConfiguration(temperature: 0.5, maxTokens: 1000, topP: 0.7),
      prompts: RolePrompt(systemPrompt: "你是一个产品经理", userPrompt: "你是一个产品经理")
    ),
    AgentRole(
      id: UUID(),
      name: "设计师",
      isSelectable: true,
      isModerator: true,
      icon: "paintbrush.fill",
      description: "设计师角色",
      isCustom: false,
      backgroundColor: .yellow,
      isUser: false,
      configuration: RoleConfiguration(temperature: 0.5, maxTokens: 1000, topP: 0.7),
      prompts: RolePrompt(systemPrompt: "你是一个设计师", userPrompt: "你是一个设计师")
    ),
    AgentRole(
      id: UUID(),
      name: "开发工程师",
      isSelectable: true,
      isModerator: true,
      icon: "hammer.fill",
      description: "开发工程师角色",
      isCustom: false,
      backgroundColor: .purple,
      isUser: false,
      configuration: RoleConfiguration(temperature: 0.5, maxTokens: 1000, topP: 0.7),
      prompts: RolePrompt(systemPrompt: "你是一个开发工程师", userPrompt: "你是一个开发工程师")
    ),
  ]
}
