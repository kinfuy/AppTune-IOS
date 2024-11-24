import SwiftUI

// MARK: - 页面路由定义
enum GeneralRouterDestination {
  case login  // 登录
  case setting  // 设置
  case accountSetting  // 账号设置
  case emailLogin  // 邮箱登录
  case aboutAuthor  //关于作者
  case userProfile  // 用户详情
  case coinTasks  // 积分任务
  case coinShop  // 积分商店
  case productDetail  // 产品详情
  case publishProduct  // 发布产品
  case publishActivity  // 发布活动

  static func isWhiteListRoute(to: GeneralRouterDestination) -> Bool {
    let authRoutes: [GeneralRouterDestination] = [.login, .emailLogin]
    return authRoutes.contains(where: { $0 == to })
  }
}

enum SheetDestination: Hashable {
    
}

enum FullScreenDestination: Hashable {
}

// MARK: - 视图构建器
extension GeneralRouterDestination {
  @ViewBuilder
  func buildView() -> some View {
      switch self {
      case .login:
          LoginView()
      case .setting:
          UserSettingView()
      case .accountSetting:
          UserAccountView()
      case .emailLogin:
          EmailLoginView()
      case .aboutAuthor:
          AboutAuthorView()
      case .userProfile:
          UserProfileView()
      case .coinTasks:
          CoinTasksView()
      case .coinShop:
          CoinShopView()
      case .publishProduct:
          PublishProductView()
      case .publishActivity:
          PublishActivityView()
      case .productDetail:
          ProductDetailView()
      }
  }
}
