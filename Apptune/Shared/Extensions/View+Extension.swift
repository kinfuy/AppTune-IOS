import SwiftUI

// 创建一个自定义的环境键
private struct KeyboardTypeKey: EnvironmentKey {
  static let defaultValue: UIKeyboardType = .default
}

// 扩展 EnvironmentValues 以添加我们的自定义键
extension EnvironmentValues {
  var keyboardType: UIKeyboardType {
    get { self[KeyboardTypeKey.self] }
    set { self[KeyboardTypeKey.self] = newValue }
  }
}

// 扩展 View 以添加便捷修饰符
extension View {
  func defaultKeyboard(_ type: UIKeyboardType = .default) -> some View {
    environment(\.keyboardType, type)
  }
}

// 扩展 TextField 和 TextEditor 以使用环境值
extension TextField {
  func useEnvironmentKeyboard() -> some View {
    self.modifier(KeyboardTypeModifier())
  }
}

extension TextEditor {
  func useEnvironmentKeyboard() -> some View {
    self.modifier(KeyboardTypeModifier())
  }
}

// 创建修饰符来应用环境键盘类型
struct KeyboardTypeModifier: ViewModifier {
  @Environment(\.keyboardType) var keyboardType

  func body(content: Content) -> some View {
    content.keyboardType(keyboardType)
  }
}

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

  // 添加新的键盘设置修饰符
  func systemKeyboard() -> some View {
    if let textField = self as? TextField<Text> {
      return AnyView(textField.keyboardType(.default))
    } else if let textEditor = self as? TextEditor {
      return AnyView(textEditor.keyboardType(.default))
    }
    return AnyView(self)
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

// 扩展 TextField 添加默认键盘设置
extension TextField {
  func useSystemKeyboard() -> some View {
    self.keyboardType(.default)
  }
}

// 扩展 TextEditor 添加默认键盘设置
extension TextEditor {
  func useSystemKeyboard() -> some View {
    self.keyboardType(.default)
  }
}
