import Foundation

class SelectChatViewModel: ObservableObject {
  @Published private(set) var customRoles: Set<AgentRole> = []
  @Published private(set) var moderator: AgentRole? = nil
  @Published var selectedGroup: RoleGroup? = nil

  private let roleManager = RoleManager.shared

  func toggleCustomRole(_ role: AgentRole) {
    if selectedGroup != nil {
      selectedGroup = nil
    }

    if customRoles.contains(where: { $0.id == role.id }) {
      customRoles.remove(role)
      if moderator?.id == role.id {
        setModerator(nil)
      }
    } else {
      customRoles.insert(role)
    }
  }

  func setModerator(_ role: AgentRole?) {
    moderator = role
    roleManager.setModerator(role)
  }

  func selectGroup(_ group: RoleGroup) {
    if selectedGroup?.id == group.id {
      selectedGroup = nil
    } else {
      selectedGroup = group
    }
  }

  func getActiveRoles(from roles: [AgentRole]) -> [AgentRole] {
    var activeRoles = Array(roles)
    if let mod = moderator {
      activeRoles = activeRoles.map { role in
        if role.id == mod.id {
          return mod
        }
        return role
      }
    }
    return activeRoles
  }
}
