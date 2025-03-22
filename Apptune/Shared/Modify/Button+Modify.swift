import SwiftUI

extension View {
  func buttonStyle(_ bgColor: Color, _ sizeColor: Color = .white, _ radius: CGFloat = 16)
    -> some View
  {
    frame(height: 42)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(bgColor)
      .cornerRadius(radius)
      .foregroundColor(sizeColor)
  }

  func primaryButton() -> some View {
    frame(height: 36)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .foregroundColor(.white)
      .background(
        LinearGradient(
          colors: [.theme, Color(hex: "#0D92F4")],
          startPoint: .leading,
          endPoint: .trailing)
      )
      .cornerRadius(16)
  }

  func loadingButton(loading: Bool) -> some View {
    HStack(spacing: 2) {
      self
      if loading {
        RotatingSymbol(size: 16)
          .transition(.opacity)
      }
    }
    .opacity(loading ? 0.6 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: loading)
  }
}
