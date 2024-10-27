import SwiftUI

extension View {
  func buttonStyle(_ bgColor: Color, _ sizeColor: Color = .white) -> some View {
    frame(height: 36)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(bgColor)
      .cornerRadius(16)
      .foregroundColor(sizeColor)
  }

  func primaryButton() -> some View {
    frame(height: 36)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .foregroundColor(.white)
      .background(
        LinearGradient(
          colors: [.theme, .blue.opacity(0.6)],
          startPoint: .leading,
          endPoint: .trailing)
      )
      .cornerRadius(16)
  }

  func loadingButton(loading: Bool) -> some View {
    HStack(spacing: 2) {
      self
        .padding(.leading, 16)
      if loading {
        RotatingSymbol(size: 16)
      } else {
        Color.clear.frame(width: 16, height: 16)
      }
    }
  }
}
