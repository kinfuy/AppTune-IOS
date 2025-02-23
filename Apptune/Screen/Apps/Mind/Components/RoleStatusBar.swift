import SwiftUI

struct RoleStatusBar: View {
  var activeRoles: Set<AgentRole>
  var typingRole: AgentRole?

  private var sortedRoles: [AgentRole] {
    Array(activeRoles).sorted { role1, role2 in
      switch (role1.id == typingRole?.id, role2.id == typingRole?.id) {
      case (true, false): return true
      case (false, true): return false
      default: return role1.name < role2.name
      }
    }
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(sortedRoles, id: \.id) { role in
            RoleStatusTag(
              role: role,
              status: getStatusText(for: role),
              isTyping: role.id == typingRole?.id,
              isModerator: role.isModerator
            )
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.spring(duration: 0.5), value: sortedRoles)
        .animation(.spring(duration: 0.5), value: typingRole)
        .onChange(of: typingRole) { _ in
          withAnimation {
            proxy.scrollTo(sortedRoles.first?.id, anchor: .leading)
          }
        }
      }
      .background(Color(.systemBackground))
    }
  }

  private func getStatusText(for role: AgentRole) -> String {
    if role.id == typingRole?.id {
      return "思考中..."
    } else {
      return "在线"
    }
  }
}

private struct RoleStatusTag: View {
  let role: AgentRole
  let status: String
  let isTyping: Bool
  let isModerator: Bool

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: role.icon)
        .font(.system(size: 12))

      Text(role.name)
        .font(.system(size: 12, weight: .medium))

      if isModerator {
        Image(systemName: "star.fill")
          .font(.system(size: 8))
          .foregroundColor(.yellow)
      }

      Text("·")
        .foregroundColor(.gray)

      Text(status)
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .fill(role.backgroundColor.opacity(0.1))
    )
    .foregroundColor(role.backgroundColor)
  }
}

// 添加预览代码
#Preview {
  RoleStatusBar(
    activeRoles: Set([
      AgentRole.defaultRoles[1],
      AgentRole.defaultRoles[2],
      AgentRole.defaultRoles[3],
    ]),
    typingRole: AgentRole.defaultRoles[3]
  )
}
