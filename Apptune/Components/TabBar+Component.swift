//
//  ContentView.swift
//  CustomTabbarSwiftUI
//
//  Created by Zeeshan Suleman on 03/03/2023.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
  case home = 0
  case person = 1

  static func isWhiteListTabbar(to: TabbedItems) -> Bool {
    return !to.requiresAuth
  }

  var title: String {
    switch self {
    case .home:
      return "产品"
    case .person:
      return "我的"
    }
  }

  var iconName: SFSymbol {
    switch self {
    case .home:
      return SFSymbol.card
    case .person:
      return SFSymbol.person
    }
  }

  var requiresAuth: Bool {
    switch self {
    case .home:
      return false
    default:
      return true
    }
  }
}

struct MainTabbedView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var sheet: SheetManager

  private func handleTabSelection(_ item: TabbedItems) {
    if !TabbedItems.isWhiteListTabbar(to: item) && !UserService.shared.isLogin {
      withAnimation {
        router.navigate(to: .login)
      }
      return
    }

    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      Tap.shared.play(.light)
      router.currentTab = item
    }
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView(selection: $router.currentTab) {
        ProductView()
          .tag(TabbedItems.home)
        UserView()
          .tag(TabbedItems.person)
      }

      // TabBar 背景
      HStack(spacing: 0) {
        CustomTabItem(item: .home, isSelected: router.currentTab == .home)
          .frame(maxWidth: .infinity)
          .onTapGesture {
            handleTabSelection(.home)
          }

        Rectangle()
          .fill(Color.clear)
          .frame(width: 86)

        CustomTabItem(item: .person, isSelected: router.currentTab == .person)
          .frame(maxWidth: .infinity)
          .onTapGesture {
            handleTabSelection(.person)
          }
      }
      .frame(height: 82)
      .background(
        TabBarBackground()
          .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: -4)
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 8)

      // 悬浮的添加按钮
      AddButton()
        .offset(y: -36)
    }
  }
}

// 自定义 TabBar 背景形状
struct TabBarBackground: View {
  var body: some View {
    CustomShape()
      .fill(Color.white)
      .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: -4)
  }
}

// 自定义形状，包含中间凹陷的弧度
struct CustomShape: Shape {
  func path(in rect: CGRect) -> Path {
    let width = rect.width
    let height = rect.height
    let centerWidth: CGFloat = 86
    let centerHeight: CGFloat = 36
    let cornerRadius: CGFloat = 26

    var path = Path()

    // 左上圆角
    path.move(to: CGPoint(x: cornerRadius, y: 0))

    // 左边到凹陷处
    path.addLine(to: CGPoint(x: (width - centerWidth) / 2, y: 0))

    // 左侧凹陷曲线
    path.addCurve(
      to: CGPoint(x: (width - centerWidth) / 2 + centerWidth / 4, y: centerHeight),
      control1: CGPoint(x: (width - centerWidth) / 2, y: 0),
      control2: CGPoint(x: (width - centerWidth) / 2 + centerWidth / 8, y: centerHeight)
    )

    // 中间凹陷曲线
    path.addCurve(
      to: CGPoint(x: (width + centerWidth) / 2 - centerWidth / 4, y: centerHeight),
      control1: CGPoint(x: width / 2, y: centerHeight + 8),
      control2: CGPoint(x: width / 2, y: centerHeight + 8)
    )

    // 右侧凹陷曲线
    path.addCurve(
      to: CGPoint(x: (width + centerWidth) / 2, y: 0),
      control1: CGPoint(x: (width + centerWidth) / 2 - centerWidth / 8, y: centerHeight),
      control2: CGPoint(x: (width + centerWidth) / 2, y: 0)
    )

    // 完成其余路径
    path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
    path.addQuadCurve(
      to: CGPoint(x: width, y: cornerRadius),
      control: CGPoint(x: width, y: 0)
    )
    path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
    path.addQuadCurve(
      to: CGPoint(x: width - cornerRadius, y: height),
      control: CGPoint(x: width, y: height)
    )
    path.addLine(to: CGPoint(x: cornerRadius, y: height))
    path.addQuadCurve(
      to: CGPoint(x: 0, y: height - cornerRadius),
      control: CGPoint(x: 0, y: height)
    )
    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
    path.addQuadCurve(
      to: CGPoint(x: cornerRadius, y: 0),
      control: CGPoint(x: 0, y: 0)
    )

    return path
  }
}

struct CustomTabItem: View {
  let item: TabbedItems
  let isSelected: Bool

  @State private var iconScale: CGFloat = 1
  @State private var yOffset: CGFloat = 0

  var body: some View {
    VStack(spacing: 6) {
      ZStack {
        if isSelected {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  Color.theme.opacity(0.12),
                  Color.theme.opacity(0.06),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 44, height: 44)
            .matchedGeometryEffect(id: "background", in: namespace)
        }

        item.iconName
          .resizable()
          .renderingMode(.template)
          .frame(width: 22, height: 22)
          .foregroundColor(isSelected ? Color.theme : Color(.systemGray3))
          .scaleEffect(iconScale)
          .offset(y: yOffset)
      }

      Text(item.title)
        .font(.system(size: 11, weight: isSelected ? .medium : .regular))
        .foregroundColor(isSelected ? Color.theme : Color(.systemGray2))
    }
    .frame(maxWidth: .infinity)
    .frame(height: 62)
    .contentShape(Rectangle())
    .onChange(of: isSelected) { newValue in
      if newValue {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
          iconScale = 1.15
          yOffset = -2
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
          iconScale = 1
          yOffset = 0
        }
      }
    }
  }

  @Namespace private var namespace
}

struct AddButton: View {
  @EnvironmentObject var sheet: SheetManager
  @State private var isPressed = false
  @State private var isRotating = false

  var body: some View {
    ZStack {
      // 外层光晕
      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color.theme.opacity(0.15),
              Color.theme.opacity(0.08),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 68, height: 68)

      // 主按钮背景
      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color.theme,
              Color.theme.opacity(0.85),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 58, height: 58)
        .shadow(
          color: Color.theme.opacity(0.25),
          radius: 10,
          x: 0,
          y: 4
        )

      // 内部装饰圆环
      Circle()
        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        .frame(width: 50, height: 50)

      // 加号图标
      Image(systemName: "plus")
        .font(.system(size: 24, weight: .medium))
        .foregroundColor(.white)
        .rotationEffect(.degrees(isRotating ? 45 : 0))
    }
    .frame(width: 72)
    .scaleEffect(isPressed ? 0.94 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    .contentShape(Rectangle())
    .pressEvents {
      withAnimation(.easeInOut(duration: 0.2)) {
        isPressed = true
        isRotating = true
      }
    } onRelease: {
      withAnimation(.easeInOut(duration: 0.2)) {
        isPressed = false
        isRotating = false
        Tap.shared.play(.medium)
        sheet.show(.createType)
      }
    }
  }
}

// 添加按压事件检测的 ViewModifier
struct PressEventsModifier: ViewModifier {
  var onPress: () -> Void
  var onRelease: () -> Void

  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in onPress() }
          .onEnded { _ in onRelease() }
      )
  }
}

// 扩展 View 以添加按压事件检测
extension View {
  func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
    modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
  }
}
