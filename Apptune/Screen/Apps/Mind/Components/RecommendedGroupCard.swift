import SwiftUI

struct RecommendedGroupCard: View {
  let roles: [ProductRole]
  let isActive: Bool
  let action: () -> Void

  private var groupName: String {
    ProductRole.recommendedGroups.first { $0.roles == roles }?.name ?? ""
  }

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        Text(groupName)
          .font(.headline)
          .foregroundColor(isActive ? .white : .primary)

        HStack(spacing: -8) {
          ForEach(roles) { role in
            Image(systemName: role.icon)
              .font(.caption)
              .foregroundColor(isActive ? .white : role.backgroundColor)
              .padding(4)
              .background(
                Circle()
                  .fill(isActive ? role.backgroundColor : role.backgroundColor.opacity(0.1))
              )
          }
        }

        Text(roles.map(\.rawValue).joined(separator: " + "))
          .font(.caption)
          .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
          .lineLimit(2)
      }
      .frame(width: 160, height: 120)
      .padding()
      .background(isActive ? Color.blue : Color(.systemBackground))
      .cornerRadius(16)
      .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
    .buttonStyle(PlainButtonStyle())
  }
}
