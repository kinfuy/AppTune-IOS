//
//  SFSymbol.swift
//  milestone
//
//  Created by 杨杨杨 on 2023/9/16.
//

import SwiftUI

enum SFSymbol: String, Codable {
  case col = "rectangle.grid.1x2"
  case row = "square.grid.2x2"
  case add = "plus"
  case close = "xmark"
  case back = "chevron.backward"
  case set = "gearshape"
  case warn = "exclamationmark.triangle"
  case success = "checkmark"
  case minus
  case icloud = "link.icloud"
  case rightArrow = "chevron.right"
  case edit = "square.and.pencil"
  case delete = "trash"
  case refresh = "goforward"
  case tray
  case card = "square.3.layers.3d.down.backward"
  case time = "clock.arrow.2.circlepath"
  case group = "books.vertical"
  case ellipsis
  case menu = "list.dash"
  case folder
  case eye
  case upDown = "arrow.up.arrow.down"
  case down = "chevron.down"
  case top = "arrow.up.to.line.compact"
  case bottom = "arrow.down.to.line.compact"
  case tips = "exclamationmark.circle"
  case pause = "pause.circle"
  case stop = "stop.circle"
  case play = "play.circle"
  case remove = "minus.circle"
  case person
  case scan = "camera.metering.none"
  case bell
  case coin = "diamond.circle"
  case search = "magnifyingglass"
  case rightShare = "arrowshape.turn.up.right.fill"
  case email = "envelope"
  case apple = "apple.logo"
  case loading = "arrow.triangle.2.circlepath"
  case task = "star.circle"
  case shop = "cart.circle"
  case message = "message"
  case community = "lasso.badge.sparkles"
}

extension SFSymbol: View {
  var body: Image {
    Image(systemName: rawValue)
  }

  func resizable() -> Image {
    body.resizable()
  }

  func renderingMode(renderingMode: Image.TemplateRenderingMode) -> Image {
    body.renderingMode(renderingMode)
  }

  func color(_ color: Color) -> some View {
    body.foregroundColor(color)
  }
}

struct RotatingSymbol: View {
  @State private var isAnimating = false
  var size: CGFloat = 14
  var color: Color = .white
  var name: SFSymbol = .loading
  var body: some View {
    name
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
      .foregroundColor(color)
      .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
      .animation(
        Animation.linear(duration: 1.0)
          .repeatForever(autoreverses: false), value: isAnimating
      )
      .onAppear {
        isAnimating = true
      }
  }
}
