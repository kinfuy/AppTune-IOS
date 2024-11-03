import SwiftUI

struct ScreenManage: View {
  @StateObject var appState = AppState.shared
  @StateObject var router = Router.shared
  @StateObject var notice = NoticeManager.shared
  @StateObject var userService = UserService.shared
  @StateObject var sheet = SheetManager.shared

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
              .onAppear {
                let auth = router.checkAuth(to: route)
                if !auth {
                  DispatchQueue.main.async {
                    router.navigate(to: .login)
                  }
                }
              }
          }
        }
        .environmentObject(appState)
        .environmentObject(router)
        .environmentObject(notice)
        .environmentObject(userService)
        .environmentObject(sheet)
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
        }

        // 只在非 sheet 状态下显示 notice
        if notice.isNotice && !sheet.isPresented {
            NoticeManager.shared.buildNoticeView(notice: notice.currentNotice!)
                .environmentObject(appState)
                .environmentObject(router)
                .environmentObject(notice)
                .environmentObject(userService)
                .environmentObject(sheet)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.black.opacity(0.01))
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
