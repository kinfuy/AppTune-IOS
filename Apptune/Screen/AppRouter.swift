//
//  AppRouter.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/15.
//

import SwiftUI

struct NoticeConfig {
  var maskHiden: Bool
  var mask: Bool
}

struct Toast {
  var id: UUID = UUID()
  var msg: String
  var autoClose: Bool = true
  var time: CGFloat = 1.5
  var loading: Bool = false
  var clickMask: Bool = true

  mutating func close() {
    loading = false
  }
}

struct Confirm {
  var id: UUID = UUID()
  var title: String
  var desc: String = ""
  var onCancel: (() -> Void)?
  var onSuccess: () -> Void
}

// MARK: 页面

enum GeneralRouterDestination {
  case login  // 登录
  case setting  // 设置
  case accountSetting  // 账号设置
  case emailLogin  // 邮箱登录
  case aboutAuthor  //关于作者
  case userProfile  // 用户详情

  static func isWhiteListRoute(to: GeneralRouterDestination) -> Bool {
    let authRoutes: [GeneralRouterDestination] = [.login, .emailLogin]
    return authRoutes.contains(where: { $0 == to })
  }
}

enum SheetDestination: Hashable {
}

enum FullScreenDestination: Hashable {
}

// MARK: 弹窗

enum NoticeDestiantion {
  case version(String)  // 版本更新检查
  case agreement(String)  // 用户协议同意
  case toast(Toast)  // 常规信息提示
  case confirm(Confirm)  // 确认弹窗

  var id: String {
    switch self {
    case let .agreement(id):
      id
    case let .toast(ctx):
      ctx.id.uuidString
    case let .version(id):
      id
    case let .confirm(ctx):
      ctx.id.uuidString
    }
  }

  var config: NoticeConfig {
    switch self {
    case .version:
      NoticeConfig(maskHiden: false, mask: true)
    case .toast:
      NoticeConfig(maskHiden: false, mask: false)
    default:
      NoticeConfig(maskHiden: true, mask: true)
    }
  }
}

class Router: ObservableObject {
  static let shared = Router()

  @Published var noticeStack: [NoticeDestiantion] = []

  @Published var currentNotice: NoticeDestiantion?
  @Published var currentTab: TabbedItems = .home
  @Published var isTabViewHidden: Bool = false
  @MainActor @Published var path = NavigationPath()

  private var paths: [GeneralRouterDestination] = []

  var isNotice: Bool {
    return currentNotice != nil
  }

  @MainActor
  @discardableResult
  func openNotice(open: NoticeDestiantion) -> String {
    noticeStack.append(open)
    withAnimation(.easeIn(duration: 0.38)) {
      currentNotice = open
    }
    if case let NoticeDestiantion.toast(ctx) = open {
      if ctx.autoClose {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(ctx.time)) {
          self.closeNotice(id: ctx.id.uuidString)
        }
      }
    }
    return open.id
  }

  @MainActor
  func closeNotice(id: String? = nil) {
    if let noticeId = id {
      noticeStack = noticeStack.filter { $0.id != noticeId }
    } else {
      if !noticeStack.isEmpty {
        noticeStack.removeLast()
      }
    }
    popNotice()
  }

  func popNotice() {
    if let last = noticeStack.last {
      currentNotice = last
    } else {
      currentNotice = nil
    }
  }

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

  @MainActor
  func navigate(to destination: GeneralRouterDestination) {
    if !checkAuth(to: destination) {
      path = NavigationPath()
      paths = []
      currentTab = .home
      path.append(GeneralRouterDestination.login)
      return
    }

    // 检查是否与最后一个路由相同
    if let lastPath = paths.last, lastPath == destination {
      return  // 如果是相同路由，直接返回不做处理
    }

    path.append(destination)
    paths.append(destination)
  }

  // periphery:ignore
  @MainActor
  func popToTabBar(_ home: Bool = true) {
    path = NavigationPath()
    paths = []
    if home {
      currentTab = .home
    }
  }

  @MainActor
  func back(to numberOfScreen: Int = 1) {
    guard numberOfScreen <= path.count else {
      print("没有足够的屏幕可以返回")
      return
    }

    var itemsToCheck = [GeneralRouterDestination]()

    for i in 0..<numberOfScreen {
      itemsToCheck.append(paths[path.count - i - 1])
    }

    // 检查每个目标是否需要权限
    for destination in itemsToCheck.suffix(numberOfScreen) {
      if !checkAuth(to: destination) {
        print("当前路径需要身份验证")
        return
      }
    }

    path.removeLast(numberOfScreen)
    paths.removeLast(numberOfScreen)
  }

  static func buildNavigationDestination(route: GeneralRouterDestination) -> some View {
    switch route {
    case .login:
      AnyView(LoginView())
    case .setting:
      AnyView(UserSettingView())
    case .accountSetting:
      AnyView(UserAccountView())
    case .emailLogin:
      AnyView(EmailLoginView())
    case .aboutAuthor:
      AnyView(AboutAuthorView())
    case .userProfile:
      AnyView(UserProfileView())
    }
  }

  static func buildNotice(notice: NoticeDestiantion) -> some View {
    ZStack {
      VStack {}
        .frame(
          maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: .infinity
        )
        .ignoresSafeArea(.all)
        .background(notice.config.mask ? .black.opacity(0.48) : .clear)
        .onTapGesture {
          if notice.config.maskHiden {
            DispatchQueue.main.async {
              Router.shared.closeNotice(id: notice.id)
            }
          }
        }
      switch notice {
      case .version:
        Version_Modal()
      case .agreement:
        Agreement_Model()
      case let .toast(notice):
        Toast_Modal(
          id: notice.id.uuidString,
          messgae: notice.msg,
          time: notice.time,
          loading: notice.loading
        )
      case let .confirm(ctx):
        Confirm_Modal(
          id: ctx.id.uuidString,
          titile: ctx.title,
          desc: ctx.desc,
          onSubmit: ctx.onSuccess,
          onCancel: ctx.onCancel ?? {}
        )
      }
    }
    // 覆盖弹出层
    .background(.black.opacity(0.01))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @MainActor
  func handleSwipeBack() {
    // 确保至少有两个页面（当前页面和返回目标页面）
    if paths.count > 1 {
      // 检查倒数第二个页面（返回的目标页面）是否有权限
      let targetDestination = paths[paths.count - 2]
      if checkAuth(to: targetDestination) {
        back()
      } else {
        // 如果没有权限，清空导航栈并导航到登录页
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
