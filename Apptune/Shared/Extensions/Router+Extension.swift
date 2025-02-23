import SwiftUI

extension View {
  func interactivePopGesture(enable: Bool, onTrigger: @escaping () -> Void) -> some View {
    modifier(InteractivePopGestureModifier(enable: enable, onTrigger: onTrigger))
  }
}

struct InteractivePopGestureModifier: ViewModifier {
  let enable: Bool
  let onTrigger: () -> Void

  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false

  func body(content: Content) -> some View {
    ZStack {
      content

      if isDragging {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Path { path in
              let height: CGFloat = 120
              let width = dragOffset
              let yOffset = (geometry.size.height - height) / 2

              path.move(to: CGPoint(x: 0, y: yOffset))
              path.addQuadCurve(
                to: CGPoint(x: 0, y: yOffset + height),
                control: CGPoint(x: width * 0.7, y: yOffset + height / 2)
              )
              path.addLine(to: CGPoint(x: 0, y: yOffset + height))
              path.addLine(to: CGPoint(x: 0, y: yOffset))
              path.closeSubpath()
            }
            .fill(Color.black.opacity(0.15))

            Rectangle()
              .fill(Color.white)
              .frame(width: 2, height: 15)
              .padding(.leading, 4)
              .frame(maxHeight: .infinity)
              .opacity(min(dragOffset / 40.0, 1.0))
          }
        }
        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: dragOffset)
      }
    }
    .gesture(
      DragGesture(minimumDistance: 10, coordinateSpace: .local)
        .onChanged { value in
          if enable && value.startLocation.x < 30 {
            isDragging = true
            dragOffset = min(max(0, value.translation.width), 100)
          }
        }
        .onEnded { value in
          if enable && value.startLocation.x < 30 {
            if value.translation.width > 50 {
              withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = 100
              }
              Tap.shared.play(.light)

              DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onTrigger()
                withAnimation(.none) {
                  dragOffset = 0
                }
              }
            } else {
              withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                dragOffset = 0
              }
            }
            isDragging = false
          }
        }
    )
    .onAppear {
      dragOffset = 0
      isDragging = false
    }
  }
}
