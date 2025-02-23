import SwiftUI

struct RecommendedGroupCard: View {
  let group: RoleGroup
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: group.icon)
            .foregroundColor(.blue)
            .font(.title3)

          Text(group.name)
            .font(.headline)

          Spacer()

          Text("\(group.roles.count)人")
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Text(group.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(2)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(group.roles, id: \.id) { role in
              Text(role.name)
                .font(.system(size: 12))
                .color(.gray)
            }
          }
        }
      }
      .padding()
      .frame(width: 280)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color(.systemBackground))
          .shadow(
            color: isActive ? .blue.opacity(0.3) : .black.opacity(0.05),
            radius: 8, y: 4
          )
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
          )
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  Group {
    // 使用单个预览组进行预览
    RecommendedGroupCard(
      group: RoleGroup(
        id: UUID(),
        name: "产品设计组",
        description: "产品经理和设计师的完美组合，专注于产品创新和用户体验",
        roles: [AgentRole.defaultRoles[0], AgentRole.defaultRoles[1]],
        icon: "lightbulb.fill"
      ),
      isActive: false
    ) {}
    .previewDisplayName("默认状态")

    // 激活状态预览
    RecommendedGroupCard(
      group: RoleGroup(
        id: UUID(),
        name: "全能开发组",
        description: "产品、设计、开发的黄金组合，让想法快速落地",
        roles: [AgentRole.defaultRoles[0], AgentRole.defaultRoles[1], AgentRole.defaultRoles[2]],
        icon: "lightbulb.fill"
      ),
      isActive: true
    ) {}
    .previewDisplayName("激活状态")

    // 深色模式预览
    RecommendedGroupCard(
      group: RoleGroup(
        id: UUID(),
        name: "技术评审组",
        description: "多个开发工程师组成的技术评审小组，深入讨论技术方案",
        roles: [AgentRole.defaultRoles[2], AgentRole.defaultRoles[2]],
        icon: "hammer.fill"
      ),
      isActive: false
    ) {}
    .previewDisplayName("深色模式")
  }
  .previewLayout(.sizeThatFits)
  .padding()
}
