import SwiftUI

struct AgentTag: View {
  let role: ProductRole
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: role.icon)
      Text(role.rawValue)
    }
    .font(.subheadline)
    .foregroundColor(isSelected ? .white : role.backgroundColor)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(isSelected ? role.backgroundColor : role.backgroundColor.opacity(0.1))
    .cornerRadius(20)
  }
}
