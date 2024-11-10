import SwiftUI

struct TitleBar: View {
  let title: String
  let showPublish: Bool
  let onPublish: () -> Void
  let isSticky: Bool
  var pubText:String = "发布"

  var body: some View {
    HStack {
      Text(title)
            .font(.system(size: 28))
            .fontWeight(.bold)
      Spacer()

      if showPublish {
        Button(action: onPublish) {
          HStack(spacing: 4) {
            Image(systemName: "plus.circle.fill")
            Text(pubText)
          }
          .foregroundColor(.theme)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color.theme.opacity(0.1))
          .cornerRadius(16)
        }
      } else {
        Color.clear
          .frame(width: 72, height: 32)
      }
    }
    .frame(height: 50)
    .padding(.horizontal)
    .background(isSticky ? Color(hex: "#f4f4f4") : .clear)
  }
}
