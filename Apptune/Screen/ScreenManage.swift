import SwiftUI

struct ScreenManage: View {
    @StateObject var appState = AppState.shared
    @StateObject var router = Router.shared
    @StateObject var userService = UserService.shared

    @State private var launchViewAlpha: CGFloat = 1
    @State private var showGuide = false

    var body: some View {
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
                    Router.buildNavigationDestination(route: route)
                        .environmentObject(appState)
                        .environmentObject(router)
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
            .environmentObject(userService)
            .opacity(launchViewAlpha == 1 ? 0 : 1)

            if router.isNotice {
                Router.buildNotice(notice: router.currentNotice!)
                    .environmentObject(appState)
                    .environmentObject(router)
                    .transition(.opacity)
                    .zIndex(1)
            }

            // 启动页
            LaunchView()
                .opacity(launchViewAlpha)
                .animation(.default, value: launchViewAlpha)
        }
        .onAppear {
            // 延迟 1 秒显示启动页
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 1.25)) {
                    launchViewAlpha = 0
                }
            }
        }
        .preferredColorScheme(.light)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ScreenManage()
}
