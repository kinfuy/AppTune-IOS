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
            .foregroundColor(.white)
            .frame(width: ProductConstants.iconSize, height: ProductConstants.iconSize)
            .background(module.color)
            .clipShape(RoundedRectangle(cornerRadius: ProductConstants.cornerRadius / 2))
            .shadow(color: module.color.opacity(0.3), radius: 4, y: 2)

          Spacer()

          if let primaryBadge = module.badges.sorted(by: { $0.priority > $1.priority }).first {
            BadgeView(badge: primaryBadge)
          }
        }

        VStack(alignment: .leading, spacing: 6) {
          Text(module.title)
            .font(.headline)
            .foregroundColor(.primary)
            .lineLimit(1)

          Text(module.description)
            .font(.caption)
            .foregroundColor(.secondary)
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
  }
}
