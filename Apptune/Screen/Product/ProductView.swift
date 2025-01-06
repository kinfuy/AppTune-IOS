//
//  ProductView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/16.
//

import SwiftUI

// 添加按钮配置结构
private struct TabActionButton {
  let show: Bool
  let text: String
  let action: () -> Void

  static func none() -> TabActionButton {
    TabActionButton(show: false, text: "", action: {})
  }
}

struct ProductView: View {
  @State private var selectedTab: ProductTab = .joinedEvents
  @State private var scrollOffset: CGFloat = 0
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var productService: ProductService
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var promotionService: PromotionService
  @EnvironmentObject var communityService: CommunityService
  @EnvironmentObject var userService: UserService
  @Default(\.lastProductNoticeDismissDate) var lastProductNoticeDismissDate

  private let titleBarHeight: CGFloat = 60
  let tabBarHeight: CGFloat = 70

  // 将模块定义拆分成独立的类型
  private struct ModuleDefinition {
    let tab: ProductTab
    let icon: String
    let color: Color
    let count: Int
    let roles: [String]
  }

  // 将baseModules定义为一个方法
  private func createBaseModules() -> [ModuleDefinition] {
    [
      ModuleDefinition(
        tab: .joinedEvents,
        icon: "person.2.fill",
        color: .orange,
        count: activeService.totalJoinedActive,
        roles: ["user", "developer", "admin"]
      ),
      ModuleDefinition(
        tab: .myProducts,
        icon: "cube.fill",
        color: .purple,
        count: productService.totalMyProducts,
        roles: ["user", "developer", "admin"]
      ),
      ModuleDefinition(
        tab: .myEvents,
        icon: "calendar.badge.plus",
        color: .theme,
        count: activeService.totalSelfActive,
        roles: ["developer", "admin"]
      ),
      ModuleDefinition(
        tab: .promotion,
        icon: "tag.fill",
        color: .indigo,
        count: promotionService.promotions.count,
        roles: ["developer", "admin"]
      ),
      ModuleDefinition(
        tab: .review,
        icon: "checkmark.seal.fill",
        color: .blue,
        count: productService.pendingProductReviews.count
          + activeService.pendingActiveReviews.count
          + communityService.pendingPostReviews.count,
        roles: ["admin"]
      ),
    ]
  }

  // 修改modules计算属性
  var modules: [(tab: ProductTab, icon: String, color: Color, count: Int, roles: [String])] {
    let definitions = createBaseModules()
    return
      definitions
      .filter { $0.roles.contains(userService.profile.role) }
      .map { def in
        (
          tab: def.tab,
          icon: def.icon,
          color: def.color,
          count: def.count,
          roles: def.roles
        )
      }
  }

  // 加载模块数据
  @MainActor
  func loadModuleData(tab: ProductTab) async {
    switch tab {
    case .promotion:
      await promotionService.loadPromotions()
    case .review:
      await productService.loadPendingProductReviews()
      await activeService.loadPendingActiveReviews()
      await communityService.loadPendingPostReviews()
    case .myProducts:
      await productService.loadProducts(refresh: true)
    case .myEvents:
      await activeService.loadSelfActives(refresh: true)
    case .joinedEvents:
      await activeService.loadJoinedActives(refresh: true)
    }
  }

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
            router.isShowModules = true
          }
        }
        .onAppear {
          Task {
            await loadModuleData(tab: module.tab)
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
          router.isShowModules = false
        }
      }) {
        Image(systemName: "chevron.left.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.red)
          .rotationEffect(.degrees(router.isShowModules ? 0 : 180))
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

  // 获取当前 tab 的按钮配置
  private func getTabActionButton() -> TabActionButton {
    switch selectedTab {
    case .myProducts:
      return TabActionButton(
        show: true,
        text: "发布",
        action: {
          Tap.shared.play(.light)
          router.navigate(to: .publishProduct)
        }
      )
    case .myEvents:
      return TabActionButton(
        show: true,
        text: "新建",
        action: {
          Tap.shared.play(.light)
          router.navigate(to: .publishActivity(active: nil))
        }
      )
    case .promotion:
      return TabActionButton(
        show: true,
        text: "新增",
        action: {
          Tap.shared.play(.light)
          router.navigate(to: .createPromotion)
        }
      )
    default:
      return .none()
    }
  }

  @MainActor
  private func checkFirstProduct() {
    if userService.profile.role == "user" {
      if let dismissDate = lastProductNoticeDismissDate {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        if dismissDate > sevenDaysAgo {
          return
        }
      }
      notice.open(open: .firstProduct(FIRST_PRODUCT_NOTICE_ID))
    }
  }

  var body: some View {
    ZStack {
      if !router.isShowModules {
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
        VStack(spacing: 0) {
          let actionButton = getTabActionButton()
          TitleBar(
            title: selectedTab.rawValue,
            showPublish: actionButton.show,
            onPublish: actionButton.action,
            isSticky: scrollOffset > titleBarHeight,
            pubText: actionButton.text
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
                    JoinedActiveView()
                  case .myProducts:
                    MyProductsView()
                  case .myEvents:
                    MyActicesView()
                  case .review:
                    ReviewView()
                  case .promotion:
                    PromotionView()
                  }
                }
                .padding(.vertical)
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
    .background(Color(hex: "#f4f4f4"))
    .onAppear {
      checkFirstProduct()
    }
  }
}

#Preview {
  ProductView()
    .environmentObject(Router())
    .environmentObject(NoticeManager())
    .environmentObject(ProductService())
    .environmentObject(ActiveService())
    .environmentObject(UserService())
    .environmentObject(PromotionService())
}
