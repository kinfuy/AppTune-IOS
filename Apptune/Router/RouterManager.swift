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

  func navigate(to destination: GeneralRouterDestination) {
    if !checkAuth(to: destination) {
      path = NavigationPath()
      paths = []
      currentTab = .home
      path.append(GeneralRouterDestination.login)
      return
    }

    if let lastPath = paths.last, lastPath == destination {
      return
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
  }

  func handleSwipeBack() {
    if paths.count > 1 {
      let targetDestination = paths[paths.count - 2]
      if checkAuth(to: targetDestination) {
        back()
      } else {
        path = NavigationPath()
        paths = []
        navigate(to: .login)
      }
    } else if paths.count == 1 {
      if checkAuth(tab: currentTab) {
        back()
      } else {
        path = NavigationPath()
        paths = []
        navigate(to: .login)
      }
    }
  }
}
