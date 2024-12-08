import SwiftUI

func attributedString(str: String) -> AttributedString {
  var attributedString = AttributedString(str)
  attributedString.link = nil
  return attributedString
}

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content)
    -> some View
  {
    if condition {
      transform(self)
    } else {
      self
    }
  }

  func linearGradient(_ startColor: Color, _ endColor: Color) -> some View {
    background(
      LinearGradient(
        gradient: Gradient(colors: [startColor, endColor]), startPoint: .top,
        endPoint: .bottom)
    )
  }

  func loading(_ isLoading: Bool, _ size: CGFloat = 1.5) -> some View {
    Group {
      if isLoading {
        self.overlay(content: {
          VStack {
            ProgressView()
              .scaleEffect(size, anchor: .center)
              .progressViewStyle(
                CircularProgressViewStyle(tint: Color.theme)
              )
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.ultraThinMaterial)
          .cornerRadius(16)
        })
      } else {
        self
      }
    }
  }

  // 添加点击收起键盘的功能
  func dismissKeyboardOnTap() -> some View {
    self.overlay(
      Color.clear
        .contentShape(Rectangle())
        .onTapGesture {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }
        .allowsHitTesting(false)
    )
  }
}

// 创建一个自定义修饰符来处理点击收起键盘
struct DismissKeyboardOnTap: ViewModifier {
  func body(content: Content) -> some View {
    content
      .onTapGesture {
        UIApplication.shared.dismissKeyboard()
      }
  }
}

// 扩展 UIApplication 以添加一个便捷方法来收起键盘
extension UIApplication {
  func dismissKeyboard() {
    sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil)
  }
}
