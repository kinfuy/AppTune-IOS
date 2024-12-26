import SwiftUI

@MainActor
class Router: ObservableObject {
  static let shared = Router()

  let noticeManager = NoticeManager.shared

  // 产品是否显示模块
  @Published var isShowModules: Bool = false
  @Published var currentTab: TabbedItems = .home
  @Published var isTabViewHidden: Bool = false
  @Published var path = NavigationPath()

  private var paths: [GeneralRouterDestination] = []

  var isNotice: Bool { noticeManager.isNotice }

  func checkAuth(to: GeneralRouterDestination? = nil, tab: TabbedItems? = nil) -> Bool {
    if UserService.shared.isLogin {
      return true
    }
    if let route = to {
      if GeneralRouterDestination.isWhiteListRoute(to: route) {
        return true
      }
    }

    if let tabbar = tab {
      if TabbedItems.isWhiteListTabbar(to: tabbar) {
        return true
      }
    }

    return false
  }

  func navigate(to destination: GeneralRouterDestination, isReplace: Bool = false) {
    // 登录页面的特殊处理
    if destination == .login {
      // 直接清空导航堆栈并设置登录页面
      path = NavigationPath()
      paths = []
      currentTab = .home
      // 登录页面只在 path 中显示，不记录在 paths 中
      path.append(destination)
      return
    }

    // 检查是否是重复导航
    if let lastDestination = paths.last, lastDestination == destination {
      print("防止重复导航到相同页面：\(destination)")
      return
    }

    // 权限检查
    if !checkAuth(to: destination) {
      path = NavigationPath()
      paths = []
      currentTab = .home
      // 同样，登录页面只在 path 中显示
      path.append(GeneralRouterDestination.login)
      return
    }

    // 如果当前显示的是登录页面，直接清空导航堆栈
    if path.count == 1 && paths.isEmpty {
      path = NavigationPath()
    }

    if isReplace {
      path.removeLast()
      paths.removeLast()
    }

    path.append(destination)
    paths.append(destination)
  }

  func toTabBar(_ tab: TabbedItems, isShowModules: Bool = false) {
    path = NavigationPath()
    paths = []
    currentTab = tab
    self.isShowModules = isShowModules
  }

  func back(to numberOfScreen: Int = 1) {
    guard numberOfScreen <= path.count else {
      print("没有足够的屏幕可以返回")
      return
    }

    let itemsToCheck = Array(paths.suffix(numberOfScreen))

    for destination in itemsToCheck {
      if !checkAuth(to: destination) {
        print("当前路径需要身份验证")
        return
      }
    }

    path.removeLast(numberOfScreen)
    paths.removeLast(numberOfScreen)
    syncNavigationState()
  }

  func handleSwipeBack() {
    if paths.count > 1 {
      let targetDestination = paths[paths.count - 2]
      if checkAuth(to: targetDestination) {
        back()
      } else {
        path = NavigationPath()
        paths = []
        // 登录页面只在 path 中显示
        path.append(GeneralRouterDestination.login)
      }
    } else if paths.count == 1 {
      if checkAuth(tab: currentTab) {
        back()
      } else {
        path = NavigationPath()
        paths = []
        // 登录页面只在 path 中显示
        path.append(GeneralRouterDestination.login)
      }
    }
  }

  func syncNavigationState() {
    while paths.count > path.count {
      paths.removeLast()
    }
  }

  #if DEBUG
    func printNavigationState() {
      print("当前导航路径数量: \(path.count)")
      print("当前路由堆栈: \(paths)")
    }
  #endif
}
