import SwiftUI

struct RoundedCorners: Shape {
  var topLeft: CGFloat = 0
  var topRight: CGFloat = 0
  var bottomLeft: CGFloat = 0
  var bottomRight: CGFloat = 0

  init(all: CGFloat = 0) {
    self.topLeft = all
    self.topRight = all
    self.bottomLeft = all
    self.bottomRight = all
  }

  init(
    topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0
  ) {
    self.topLeft = topLeft
    self.topRight = topRight
    self.bottomLeft = bottomLeft
    self.bottomRight = bottomRight
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))

    path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
    path.addArc(
      center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
      radius: topRight,
      startAngle: .degrees(-90),
      endAngle: .degrees(0),
      clockwise: false)

    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
    path.addArc(
      center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
      radius: bottomRight,
      startAngle: .degrees(0),
      endAngle: .degrees(90),
      clockwise: false)

    path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
    path.addArc(
      center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
      radius: bottomLeft,
      startAngle: .degrees(90),
      endAngle: .degrees(180),
      clockwise: false)

    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
    path.addArc(
      center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
      radius: topLeft,
      startAngle: .degrees(180),
      endAngle: .degrees(270),
      clockwise: false)

    return path
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: RoundedCorners) -> some View {
    clipShape(corners)
  }

  func cornerRadius(all: CGFloat) -> some View {
    clipShape(RoundedCorners(all: all))
  }
}
