import SwiftUI

struct ModuleCardView: View {
  let module: ModuleDefinition
  let onTap: (ProductTab, Bool) -> Void

  var body: some View {
    Button(action: { onTap(module.tab, module.isEnabled) }) {
      VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .top) {
          Image(systemName: module.icon)
            .font(.title2)
            .foregroundColor(module.isEnabled ? .white : .gray)
            .frame(width: ProductConstants.iconSize, height: ProductConstants.iconSize)
            .background(module.isEnabled ? module.color : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: ProductConstants.cornerRadius / 2))
            .shadow(
              color: module.isEnabled ? module.color.opacity(0.3) : Color.clear, radius: 4, y: 2)

          Spacer()

          if let primaryBadge = module.badges.sorted(by: { $0.priority > $1.priority }).first {
            BadgeView(badge: primaryBadge)
          }
        }

        VStack(alignment: .leading, spacing: 6) {
          Text(module.title)
            .font(.headline)
            .foregroundColor(module.isEnabled ? .primary : .gray)
            .lineLimit(1)

          Text(module.description)
            .font(.caption)
            .foregroundColor(module.isEnabled ? .secondary : .gray)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(height: ProductConstants.cardHeight)
      .padding(ProductConstants.cardPadding)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: ProductConstants.cornerRadius))
      .shadow(color: Color.black.opacity(0.05), radius: ProductConstants.shadowRadius, y: 4)
    }
    .buttonStyle(ScaleButtonStyle())
    .disabled(!module.isEnabled)
  }
}
