import SwiftUI

struct ModuleGroup: Identifiable {
  let id = UUID()
  let title: String
  let description: String
  let order: Int
  let modules: [ModuleDefinition]
}

struct ModuleDefinition: Identifiable {
  let id = UUID()
  let tab: ProductTab
  let icon: String
  let title: String
  let description: String
  let color: Color
  let roles: [String]
  let badges: [BadgeType]
  let order: Int
  let isEnabled: Bool
}
