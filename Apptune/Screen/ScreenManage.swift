import SwiftUI

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

  @State private var launchViewAlpha: CGFloat = 1
  @State private var showGuide = false

  var body: some View {
    // 最外层包装一个 ZStack，用于显示通知
    ZStack {
      // 主要内容包括 sheet
      ZStack {
        NavigationStack(path: $router.path) {
          ZStack {
            if showGuide {
              GuideView(showGuide: $showGuide)
                .environmentObject(appState)
                .environmentObject(router)
            } else {
              MainTabbedView()
            }
          }
          .onAppear {
            appState.checkForUpdate()
          }
          .navigationDestination(for: GeneralRouterDestination.self) { route in
            GeneralRouterDestination.buildView(route)()
              .environmentObject(appState)
              .environmentObject(router)
              .environmentObject(notice)
              .environmentObject(sheet)
              .environmentObject(userService)
              .environmentObject(productService)
              .environmentObject(promotionService)
              .environmentObject(activeService)
              .environmentObject(tagService)
              .onAppear {
                Task {
                  try? await Task.sleep(nanoseconds: 100_000_000)
                  if !router.checkAuth(to: route) {
                    await MainActor.run {
                      withAnimation(.easeInOut) {
                        router.navigate(to: .login)
                      }
                    }
                  }
                }
              }
              .transition(
                .asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .move(edge: .leading)
                ))
          }
        }
        .environmentObject(appState)
        .environmentObject(router)
        .environmentObject(notice)
        .environmentObject(userService)
        .environmentObject(sheet)
        .environmentObject(productService)
        .environmentObject(promotionService)
        .environmentObject(activeService)
        .environmentObject(tagService)
        .opacity(launchViewAlpha == 1 ? 0 : 1)
        .navigationBarBackButtonHidden(true)
        .interactivePopGesture(enable: true) {
          router.handleSwipeBack()
        }
        .sheet(
          isPresented: Binding(
            get: { sheet.isPresented && sheet.presentedSheet?.config().fullScreen == false },
            set: { if !$0 { sheet.close() } }
          )
        ) {
          sheet.buildSheetView()
            .environmentObject(appState)
            .environmentObject(router)
            .environmentObject(notice)
            .environmentObject(userService)
            .environmentObject(sheet)
            .environmentObject(productService)
            .environmentObject(promotionService)
            .environmentObject(activeService)
            .environmentObject(tagService)
        }
        .fullScreenCover(
          isPresented: Binding(
            get: { sheet.isPresented && sheet.presentedSheet?.config().fullScreen == true },
            set: { if !$0 { sheet.close() } }
          )
        ) {
          sheet.buildSheetView()
            .environmentObject(appState)
            .environmentObject(router)
            .environmentObject(notice)
            .environmentObject(userService)
            .environmentObject(sheet)
            .environmentObject(productService)
            .environmentObject(promotionService)
            .environmentObject(tagService)
        }

        // 只在非 sheet 状态下显示 notice
        if notice.isNotice && !sheet.isPresented {
          NoticeManager.shared.buildNoticeView(notice: notice.currentNotice!)
            .environmentObject(appState)
            .environmentObject(router)
            .environmentObject(notice)
            .environmentObject(userService)
            .environmentObject(sheet)
            .environmentObject(productService)
            .environmentObject(promotionService)
            .environmentObject(tagService)
            .ignoresSafeArea()
            .transition(.opacity)
        }

        // 启动页
        LaunchView()
          .opacity(launchViewAlpha)
          .animation(.default, value: launchViewAlpha)
          .zIndex(100)
      }
    }
    .onAppear {
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
}
