import SwiftUI

struct BadgeView: View {
  let badge: BadgeType
  
  var body: some View {
    Text(badge.text)
      .font(.system(size: 12, weight: .medium))
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(badge.color)
      .clipShape(Capsule())
  }
} 
