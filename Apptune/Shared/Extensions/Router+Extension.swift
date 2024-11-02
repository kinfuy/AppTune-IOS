import SwiftUI

extension View {
  func interactivePopGesture(enable: Bool, onTrigger: @escaping () -> Void) -> some View {
    modifier(InteractivePopGestureModifier(enable: enable, onTrigger: onTrigger))
  }
}

struct InteractivePopGestureModifier: ViewModifier {
  let enable: Bool
  let onTrigger: () -> Void

  func body(content: Content) -> some View {
    content.simultaneousGesture(
      DragGesture()
        .onEnded { value in
          if enable && value.translation.width > 100 {
            onTrigger()
          }
        }
    )
  }
}
