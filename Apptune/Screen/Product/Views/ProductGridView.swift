import SwiftUI

struct ProductGridView: View {
  let moduleGroups: [ModuleGroup]
  let isAnimating: Bool
  let userRoles: String
  let onModuleTap: (ProductTab, Bool) -> Void

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: ProductConstants.groupSpacing) {
        ForEach(moduleGroups.sorted(by: { $0.order < $1.order })) { group in
          let filteredModules = group.modules.filter { module in
            module.roles.count > 0 ? module.roles.contains(userRoles) : true
          }

          if !filteredModules.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
              GroupHeaderView(title: group.title, description: group.description)
              ModuleGridView(
                modules: filteredModules,
                isAnimating: isAnimating,
                onModuleTap: onModuleTap
              )
            }
          }
        }
      }
      .padding(.bottom, ProductConstants.cardPadding)
    }
  }
}

private struct GroupHeaderView: View {
  let title: String
  let description: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.primary)

      Text(description)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .lineLimit(1)
    }
    .padding(.horizontal)
  }
}

private struct ModuleGridView: View {
  let modules: [ModuleDefinition]
  let isAnimating: Bool
  let onModuleTap: (ProductTab, Bool) -> Void

  var body: some View {
    LazyVGrid(
      columns: [
        GridItem(.flexible(), spacing: ProductConstants.gridSpacing),
        GridItem(.flexible(), spacing: ProductConstants.gridSpacing),
      ],
      spacing: ProductConstants.gridSpacing
    ) {
      ForEach(modules.sorted(by: { $0.order < $1.order })) { module in
        ModuleCardView(module: module, onTap: onModuleTap)
          .opacity(isAnimating ? 1 : 0)
          .offset(y: isAnimating ? 0 : 20)
          .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
              .delay(Double(modules.firstIndex(where: { $0.id == module.id }) ?? 0) * 0.1),
            value: isAnimating
          )
      }
    }
    .padding(.horizontal)
  }
}
