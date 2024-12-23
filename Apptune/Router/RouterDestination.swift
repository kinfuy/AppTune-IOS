import SwiftUI

// MARK: - 页面路由定义

enum GeneralRouterDestination: Hashable {
  case login  // 登录
  case setting  // 设置
  case accountSetting  // 账号设置
  case emailLogin  // 邮箱登录
  case aboutAuthor  // 关于作者
  case userProfile  // 用户详情
  case coinTasks  // 积分任务
  case coinShop  // 积分商店
  case publishProduct  // 发布产品
  case publishActivity(active: ActiveInfo?)  // 发布活动
  case createPromotion  // 创建促销码
  case activeDetail(active: ActiveInfo)  // 活动详情
  case followNotice  // 关注通知
  case joinNotice  // 报名通知
  case auditNotice  // 审核通知
  case officeNotice  // 官方通知
  case submitActiveReview(active: ActiveInfo, mode: ReviewMode)
  case registration(active: ActiveInfo)  // 添加报名管理路由

  static func isWhiteListRoute(to: GeneralRouterDestination) -> Bool {
    switch to {
    case .login, .emailLogin:
      return true
    default:
      return false
    }
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
    case let .publishActivity(active):
      PublishActivityView(active: active)
    case .createPromotion:
      CreatePromotionView()
    case let .activeDetail(active):
      ActiveDetailView(active: active)
    case .followNotice:
      FollowNoticeView()
    case .joinNotice:
      JoinNoticeView()
    case .auditNotice:
      AuditNoticeView()
    case .officeNotice:
      OfficeNoticeView()
    case let .submitActiveReview(active, mode):
      SubmitActiveReviewView(active: active, mode: mode)
    case let .registration(active):
      RegistrationView(active: active)
    }
  }
}
