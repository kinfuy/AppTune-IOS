import SwiftUI

struct RoleStatusBar: View {
  let activeRoles: Set<ProductRole>
  let typingRole: ProductRole?

  // 添加计算属性来排序角色
  private var sortedRoles: [ProductRole] {
    Array(activeRoles.filter { $0 != .user }).sorted { role1, role2 in
      switch (role1 == typingRole, role2 == typingRole) {
      case (true, false): return true  // typing role comes first
      case (false, true): return false  // non-typing role comes after
      default: return role1.rawValue < role2.rawValue  // alphabetical order for same status
      }
    }
  }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(sortedRoles, id: \.self) { role in
          RoleStatusTag(
            role: role,
            status: getStatusText(for: role),
            isTyping: role == typingRole
          )
          .transition(
            .asymmetric(
              insertion: .move(edge: .leading).combined(with: .opacity),
              removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        }
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .animation(.spring(duration: 0.5), value: sortedRoles)
      .animation(.spring(duration: 0.5), value: typingRole)
    }
    .background(Color(.systemBackground))
  }

  private func getStatusText(for role: ProductRole) -> String {
    if role == typingRole {
      switch role {
      case .productManager:
        return "思考中..."
      case .designer:
        return "设计中..."
      case .developer:
        return "分析中..."
      case .marketingManager:
        return "评估中..."
      default:
        return "输入中..."
      }
    }
    return "在线"
  }
}

private struct RoleStatusTag: View {
  let role: ProductRole
  let status: String
  let isTyping: Bool

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: role.icon)
        .font(.system(size: 12))

      Text(role.rawValue)
        .font(.system(size: 12, weight: .medium))

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
    activeRoles: [.productManager, .designer, .developer],
    typingRole: .designer
  )
}
