import SwiftUI

@MainActor
class AppEnvironment: ObservableObject {
  static let shared = AppEnvironment()
  let appState = AppState.shared
  let router = Router.shared
  let notice = NoticeManager.shared
  let userService = UserService.shared
  let sheet = SheetManager.shared
  let productService = ProductService()
  let promotionService = PromotionService()
  let activeService = ActiveService()
  let tagService = TagService()
  let notificationService = NotificationService()
  let communityService = CommunityService()

  private init() {}
}

struct AppEnvironmentModifier: ViewModifier {
  @ObservedObject private var environment = AppEnvironment.shared

  func body(content: Content) -> some View {
    content
      .environmentObject(environment.appState)
      .environmentObject(environment.router)
      .environmentObject(environment.notice)
      .environmentObject(environment.userService)
      .environmentObject(environment.sheet)
      .environmentObject(environment.productService)
      .environmentObject(environment.promotionService)
      .environmentObject(environment.activeService)
      .environmentObject(environment.tagService)
      .environmentObject(environment.notificationService)
      .environmentObject(environment.communityService)
  }
}

extension View {
  func withAppEnvironment() -> some View {
    modifier(AppEnvironmentModifier())
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
                .withAppEnvironment()
            } else {
              MainTabbedView()
            }
          }
          .onAppear {
            appState.checkForUpdate()
          }
          .navigationDestination(for: GeneralRouterDestination.self) { route in
            GeneralRouterDestination.buildView(route)()
              .withAppEnvironment()
              .transition(
                .asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .move(edge: .leading)
                ))
          }
        }
        .withAppEnvironment()
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
            .if(
              sheet.presentedSheet?.config().height != nil,
              transform: { view in
                view.presentationDetents([.fraction((sheet.presentedSheet?.config().height)!)])
              }
            )
            .withAppEnvironment()
        }
        .fullScreenCover(
          isPresented: Binding(
            get: { sheet.isPresented && sheet.presentedSheet?.config().fullScreen == true },
            set: { if !$0 { sheet.close() } }
          )
        ) {
          sheet.buildSheetView()
            .withAppEnvironment()
        }

        if notice.isNotice && !sheet.isPresented {
          NoticeManager.shared.buildNoticeView(notice: notice.currentNotice!)
            .withAppEnvironment()
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
