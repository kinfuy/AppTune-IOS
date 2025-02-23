import SwiftUI

enum BadgeType {
  case new
  case beta
  case ai
  case vip
  case pro

  var text: String {
    switch self {
    case .new: return "New"
    case .beta: return "Beta"
    case .ai: return "AI"
    case .vip: return "VIP"
    case .pro: return "Pro"
    }
  }

  var priority: Int {
    switch self {
    case .new: return 5
    case .ai: return 4
    case .pro: return 3
    case .vip: return 2
    case .beta: return 1
    }
  }

  var color: Color {
    switch self {
    case .new: return .red
    case .beta: return .orange
    case .ai: return .blue
    case .vip: return .purple
    case .pro: return .indigo
    }
  }
}
