//
//  ContentView.swift
//  CustomTabbarSwiftUI
//
//  Created by Zeeshan Suleman on 03/03/2023.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
  case home = 0
  case product = 1
  case message = 2
  case person = 3

  static func isWhiteListTabbar(to: TabbedItems) -> Bool {
    return !to.requiresAuth
  }

  var title: String {
    switch self {
    case .home:
      return "活动"
    case .product:
      return "空间"
    case .message:
      return "消息"
    case .person:
      return "我的"
    }
  }

  var iconName: SFSymbol {
    switch self {
    case .home:
      return SFSymbol.card
    case .product:
      return SFSymbol.folder
    case .person:
      return SFSymbol.person
    case .message:
      return SFSymbol.message
    }
  }

  var requiresAuth: Bool {
    switch self {
    case .home:
      return false
    case .product:
      return true
    case .message:
      return true
    case .person:
      return true
    }
  }
}

struct MainTabbedView: View {
  @EnvironmentObject var router: Router

  private func handleTabSelection(_ item: TabbedItems) {
      if !TabbedItems.isWhiteListTabbar(to: item) && !UserService.shared.isLogin {
      withAnimation {
        router.navigate(to: .login)
      }
      return
    }

    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      Tap.shared.play(.light)
      router.isShowModules = false
      router.currentTab = item
    }
  }

  var body: some View {
    ZStack {
      Color(hex: "#f4f4f4")
        .ignoresSafeArea()

      ZStack(alignment: .bottom) {
        TabView(selection: $router.currentTab) {
          ActiveHomeView()
            .tag(TabbedItems.home)
          ProductView()
            .tag(TabbedItems.product)
          UserView()
            .tag(TabbedItems.person)
          Text("消息")
            .tag(TabbedItems.message)
        }

        HStack(spacing: 0) {
          ForEach(TabbedItems.allCases, id: \.self) { item in
            Button {
              handleTabSelection(item)
            } label: {
              CustomTabItem(item: item, isSelected: router.currentTab == item)
            }
            .frame(maxWidth: .infinity)
          }
        }
        .frame(height: 64)
        .background(
          Color.white
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: -3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
      }
    }
  }
}

struct CustomTabItem: View {
  let item: TabbedItems
  let isSelected: Bool

  @State private var iconScale: CGFloat = 1
  @State private var yOffset: CGFloat = 0

  var body: some View {
    VStack(spacing: 6) {
      // 图标容器
      ZStack {
        if isSelected {
          Circle()
            .fill(Color.theme.opacity(0.12))
            .frame(width: 40, height: 40)
            .matchedGeometryEffect(id: "background", in: namespace)
        }

        item.iconName
          .resizable()
          .renderingMode(.template)
          .frame(width: 22, height: 22)
          .foregroundColor(isSelected ? Color.theme : .gray.opacity(0.65))
          .scaleEffect(iconScale)
          .offset(y: yOffset)
      }

      Text(item.title)
        .font(.system(size: 11, weight: isSelected ? .medium : .regular))
        .foregroundColor(isSelected ? Color.theme : .gray.opacity(0.65))
    }
    .frame(maxWidth: .infinity)
    .frame(height: 56)
    .contentShape(Rectangle())
    .onChange(of: isSelected) { newValue in
      if newValue {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
          iconScale = 1.2
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
