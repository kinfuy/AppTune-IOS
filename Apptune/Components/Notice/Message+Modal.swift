//
//  Message+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/10.
//

import SwiftUI

enum MessagePosition {
  case top
  case center
  case bottom
}

enum MessageAlignment {
  case left
  case center
  case right
}

enum MessageTheme: Equatable {
  case dark
  case light
  case custom(background: Color, textColor: Color)

  var backgroundColor: Color {
    switch self {
    case .dark:
      return Color.black.opacity(0.64)
    case .light:
      return Color.white
    case .custom(let background, _):
      return background
    }
  }

  var textColor: Color {
    switch self {
    case .dark:
      return .white
    case .light:
      return Color.black.opacity(0.75)
    case .custom(_, let textColor):
      return textColor
    }
  }

  var shadowColor: Color {
    switch self {
    case .dark:
      return Color.black.opacity(0.1)
    case .light:
      return Color.black.opacity(0.05)
    case .custom:
      return Color.black.opacity(0.08)
    }
  }
}

struct Message_Modal: View {
  @EnvironmentObject var notice: NoticeManager
  var id: String
  var message: String = ""
  var icon: String? = nil  // SF Symbols 名称
  var customView: AnyView? = nil
  var position: MessagePosition = .top
  var alignment: MessageAlignment = .center
  var loading: Bool = false
  var time: CGFloat = 1.5
  var theme: MessageTheme = .dark  // 新增主题属性

  private var messageOffset: CGFloat {
    switch position {
    case .top: return 100
    case .center: return 0
    case .bottom: return -UIScreen.main.bounds.height / 2 + 100
    }
  }

  private var messageAlignment: Alignment {
    switch alignment {
    case .left: return .leading
    case .center: return .center
    case .right: return .trailing
    }
  }

  private struct LoadingIndicator: View {
    @State private var isRotating = false
    var color: Color  // 新增颜色参数

    var body: some View {
      Circle()
        .trim(from: 0, to: 0.7)
        .stroke(color, lineWidth: 2)  // 使用传入的颜色
        .frame(width: 14, height: 14)
        .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
        .onAppear {
          withAnimation(
            .linear(duration: 1)
              .repeatForever(autoreverses: false)
          ) {
            isRotating = true
          }
        }
    }
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 8) {
        if let customView = customView {
          customView
        } else {
          HStack(spacing: 8) {
            if loading {
              LoadingIndicator(color: theme.textColor)  // 传入主题文字颜色
            } else if let iconName = icon {
              Image(systemName: iconName)
                .foregroundColor(theme.textColor)
            }
            if message != "" {
              Text(message)
                .foregroundColor(theme.textColor)
                .font(.system(size: 14))
            }
          }
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .background(theme.backgroundColor)
      .cornerRadius(8)
      .shadow(
        color: theme.shadowColor,
        radius: {
          switch theme {
          case .light: return 8
          default: return 5
          }
        }(),
        x: 0,
        y: {
          switch theme {
          case .light: return 4
          default: return 2
          }
        }()
      )
      .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
      .position(
        x: {
          switch alignment {
          case .left: return geometry.size.width * 0.2
          case .center: return geometry.size.width / 2
          case .right: return geometry.size.width * 0.8
          }
        }(),
        y: {
          switch position {
          case .top: return 100
          case .center: return geometry.size.height / 2
          case .bottom: return geometry.size.height - 100
          }
        }()
      )
    }
  }
}

// 预览
#Preview {
  VStack {
    Message_Modal(
      id: "test1",
      message: "深色主题消息",
      icon: "info.circle",
      position: .top,
      alignment: .center,
      theme: .dark
    )

    Message_Modal(
      id: "test2",
      message: "浅色主题消息",
      icon: "bell.fill",
      position: .center,
      alignment: .center,
      theme: .light
    )

    Message_Modal(
      id: "test3",
      message: "",
      position: .bottom,
      alignment: .right,
      loading: true,
      theme: .custom(
        background: .clear,
        textColor: .blue
      )
    )
  }
}
