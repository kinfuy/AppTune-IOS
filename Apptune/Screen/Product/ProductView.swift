//
//  ProductView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/16.
//

import SwiftUI

struct ProductView: View {
  @State private var selectedTab: ProductTab = .joinedEvents
  @State private var isAnimating = false
  @State private var selectedModule: ProductTab? = nil

  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var productService: ProductService
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var promotionService: PromotionService
  @EnvironmentObject var communityService: CommunityService
  @EnvironmentObject var userService: UserService
  @Default(\.lastProductNoticeDismissDate) var lastProductNoticeDismissDate

  private func handleModuleTap(_ tab: ProductTab, isEnabled: Bool) {
    if !isEnabled {
      notice.open(open: .toast("敬请期待"))
      Tap.shared.play(.light)
      return
    }

    withAnimation(.spring()) {
      selectedTab = tab
      selectedModule = tab
    }
    Tap.shared.play(.light)
    router.navigate(to: tab.route)
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("产品中心")
          .font(.system(size: 28))
          .fontWeight(.bold)

        Spacer()

        Button(action: {
          // TODO: 添加搜索功能
        }) {
          Image(systemName: "magnifyingglass")
            .font(.title3)
            .foregroundColor(.primary)
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 0)

      ProductGridView(
        moduleGroups: ProductModules.groups,
        isAnimating: isAnimating,
        userRoles: userService.role,
        onModuleTap: { tab, isEnabled in
          handleModuleTap(tab, isEnabled: isEnabled)
        }
      )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top)
    .padding(.bottom, 32)
    .background(Color(hex: "#f4f4f4"))
    .onAppear {
      withAnimation {
        isAnimating = true
      }
    }
  }
}

// 自定义按钮动画样式
struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.spring(), value: configuration.isPressed)
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
