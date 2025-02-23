import SwiftUI

struct AgentCard: View {
  let role: ProductRole
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: role.icon)
            .font(.title2)
            .foregroundColor(isActive ? .white : role.backgroundColor)
          Spacer()
          Text(isActive ? "已选择" : "选择")
            .font(.caption)
            .foregroundColor(isActive ? .white : role.backgroundColor)
        }
        .padding(8)
        .background(isActive ? role.backgroundColor : role.backgroundColor.opacity(0.1))
        .cornerRadius(12)

        Text(role.rawValue)
          .font(.headline)
          .foregroundColor(.primary)

        Text(role.description)
          .font(.caption)
          .foregroundColor(.gray)
          .lineLimit(2)
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color(.systemBackground))
      .cornerRadius(16)
      .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(isActive ? role.backgroundColor : .clear, lineWidth: 2)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}
