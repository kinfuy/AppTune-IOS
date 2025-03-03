import SwiftUI

enum BadgeType {
  case new
  case beta
  case ai
  case vip
  case pro
  case pending

  var text: String {
    switch self {
    case .new: return "New"
    case .beta: return "Beta"
    case .ai: return "AI"
    case .vip: return "VIP"
    case .pro: return "Pro"
    case .pending: return "Soon"
    }
  }

  var priority: Int {
    switch self {
    case .new: return 5
    case .ai: return 4
    case .pro: return 3
    case .vip: return 2
    case .beta: return 1
    case .pending: return 0
    }
  }

  var color: Color {
    switch self {
    case .new: return .red
    case .beta: return .orange
    case .ai: return .blue
    case .vip: return .purple
    case .pro: return .indigo
    case .pending: return .gray
    }
  }
}
