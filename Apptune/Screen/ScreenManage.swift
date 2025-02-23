import SwiftUI

// MARK: - Environment Objects Extension
extension View {
  fileprivate func withAppEnvironment(from screen: ScreenManage) -> some View {
    self
      .environmentObject(screen.appState)
      .environmentObject(screen.router)
      .environmentObject(screen.notice)
      .environmentObject(screen.userService)
      .environmentObject(screen.sheet)
      .environmentObject(screen.productService)
      .environmentObject(screen.promotionService)
      .environmentObject(screen.activeService)
      .environmentObject(screen.tagService)
      .environmentObject(screen.notificationService)
      .environmentObject(screen.communityService)
  }
}

struct ScreenManage: View {
  @StateObject var appState = AppState.shared
  @StateObject var router = Router.shared
  @StateObject var notice = NoticeManager.shared
  @StateObject var userService = UserService.shared
  @StateObject var sheet = SheetManager.shared
  @StateObject var productService = ProductService()
  @StateObject var promotionService = PromotionService()
  @StateObject var activeService = ActiveService()
  @StateObject var tagService = TagService()
  @StateObject var notificationService = NotificationService()
  @StateObject var communityService = CommunityService()

  @State private var launchViewAlpha: CGFloat = 1
  @State private var showGuide = false

  var body: some View {
    ZStack {
      ZStack {
        NavigationStack(path: $router.path) {
          ZStack {
            if showGuide {
              GuideView(showGuide: $showGuide)
                .withAppEnvironment(from: self)
            } else {
              MainTabbedView()
            }
          }
          .onAppear {
            appState.checkForUpdate()
          }
          .navigationDestination(for: GeneralRouterDestination.self) { route in
            GeneralRouterDestination.buildView(route)()
              .withAppEnvironment(from: self)
              .transition(
                .asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .move(edge: .leading)
                ))
          }
        }
        .withAppEnvironment(from: self)
        .opacity(launchViewAlpha == 1 ? 0 : 1)
        .navigationBarBackButtonHidden(true)
        .interactivePopGesture(enable: true) {
          router.handleSwipeBack()
        }

        if let currentNotice = notice.currentNotice, !sheet.hasSheet() {
          NoticeManager.shared.buildNoticeView(notice: currentNotice)
            .withAppEnvironment(from: self)
            .ignoresSafeArea()
            .transition(.opacity)
            .zIndex(99)
        }

        // 启动页
        LaunchView()
          .opacity(launchViewAlpha)
          .animation(.default, value: launchViewAlpha)
          .zIndex(100)
      }
    }
    .onAppear {
      sheet.setEnvironmentObjects(
        appState: appState,
        router: router,
        notice: notice,
        userService: userService,
        sheet: sheet,
        productService: productService,
        promotionService: promotionService,
        activeService: activeService,
        tagService: tagService,
        notificationService: notificationService,
        communityService: communityService
      )

      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        withAnimation(.easeInOut(duration: 1.25)) {
          launchViewAlpha = 0
        }
      }
    }
    .preferredColorScheme(.light)
  }
}

#Preview {
  ScreenManage()
    .environmentObject(ActiveService())
    .environmentObject(ProductService())
    .environmentObject(PromotionService())
    .environmentObject(TagService())
    .environmentObject(NotificationService())
    .environmentObject(CommunityService())
    .environmentObject(UserService())
    .environmentObject(SheetManager())
    .environmentObject(Router())
    .environmentObject(NoticeManager())

}
