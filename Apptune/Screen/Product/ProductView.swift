//
//  ProductView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/16.
//

import SwiftUI

struct ProductView: View {
  @State private var selectedTab: ProductTab = .joinedEvents
  @State private var showModules = true
  @State private var scrollOffset: CGFloat = 0
  @EnvironmentObject var router: Router
  private let titleBarHeight: CGFloat = 60
  let tabBarHeight: CGFloat = 70

  // 模块数据
  let modules = [
    (tab: ProductTab.joinedEvents, icon: "person.2.fill", color: Color.theme, count: 5),
    (tab: ProductTab.followedProducts, icon: "star.fill", color: Color.orange, count: 8),
    (tab: ProductTab.myProducts, icon: "cube.fill", color: Color.purple, count: 3),
    (tab: ProductTab.myEvents, icon: "calendar.badge.plus", color: Color.theme, count: 2),
  ]

  // 模块卡片网格
  var moduleGrid: some View {
    LazyVGrid(
      columns: [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
      ], spacing: 16
    ) {
      ForEach(modules, id: \.tab) { module in
        ModuleCard(
          title: module.tab.rawValue,
          icon: module.icon,
          count: module.count,
          color: module.color
        ) {
          withAnimation(.spring()) {
            selectedTab = module.tab
            showModules = false
          }
        }
      }
    }
    .padding(.horizontal)
  }

  // 侧边栏
  var sidebar: some View {
    VStack(spacing: 32) {
      ForEach(modules, id: \.tab) { module in
        VStack(spacing: 4) {
          Image(systemName: module.icon)
            .font(.system(size: 24))
            .foregroundColor(selectedTab == module.tab ? module.color : .gray)
            .frame(width: 32, height: 32)
            .background(
              selectedTab == module.tab ? module.color.opacity(0.1) : Color.clear
            )
            .clipShape(Circle())

          Text("\(module.count)")
            .font(.system(size: 10))
            .foregroundColor(selectedTab == module.tab ? module.color : .gray)
        }
        .frame(height: 50)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation(.spring(response: 0.3)) {
            selectedTab = module.tab
          }
        }
      }

      Divider()
        .frame(width: 24)
        .padding(.vertical, 8)

      Button(action: {
        withAnimation(.spring(response: 0.3)) {
          Tap.shared.play(.light)
          showModules = true
        }
      }) {
        Image(systemName: "chevron.right.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.red)
          .rotationEffect(.degrees(showModules ? 0 : 180))
      }
      .frame(height: 50)
    }
    .padding(.vertical)
    .frame(width: 60)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: -2, y: 0)
    )
  }

  var body: some View {
    ZStack {
      Color(hex: "#f4f4f4").ignoresSafeArea()

      if showModules {
        // 模块入口卡片视图
        VStack(alignment: .leading, spacing: 24) {
          HStack {
            Text("我的空间")
              .font(.system(size: 28))
              .fontWeight(.bold)
            Spacer()
          }
          .padding(.horizontal)

          moduleGrid
          Spacer()
        }
        .padding(.top)
      } else {
        // 内容视图
        VStack(spacing: 0) {
          // 标题栏（固定在顶部）
          TitleBar(
            title: selectedTab.rawValue,
            showPublish: selectedTab == .myProducts || selectedTab == .myEvents,
            onPublish: {
              print("发布新\(selectedTab == .myProducts ? "产品" : "活动")")
            },
            isSticky: scrollOffset > titleBarHeight
          )
          .zIndex(1)

          // 内容区域
          GeometryReader { geometry in
            HStack(spacing: 0) {
              // 侧边栏 - 固定不滚动
              VStack {
                sidebar
                  .padding(.leading)
                  .padding(.top, 8)
                Spacer()
              }

              // 内容区域 - 可滚动
              ScrollView(showsIndicators: false) {
                // 用于检测滚动偏移量
                GeometryReader { geometry in
                  Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                  )
                }
                .frame(height: 0)

                // 内容
                VStack {
                  switch selectedTab {
                  case .joinedEvents:
                    JoinedEventsView()
                  case .followedProducts:
                    FollowedProductsView()
                  case .myProducts:
                    MyProductsView()
                  case .myEvents:
                    MyEventsView()
                  }
                }
                .padding(.top, 0)
                .padding(.bottom, tabBarHeight)
                .animation(.none, value: selectedTab)
              }

              .coordinateSpace(name: "scroll")
              .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
              }
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.bottom, 32)
    .onChange(of: router.currentTab) { oldValue, newValue in
      if oldValue == .product && newValue != .product {
        showModules = true
      }
    }
  }
}

#Preview {
  ProductView()
}
