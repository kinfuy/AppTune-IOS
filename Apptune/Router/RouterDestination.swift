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
  case submitActiveReview(active: ActiveInfo, mode: ReviewMode, userId: String?)
  case registration(active: ActiveInfo)  // 添加报名管理路由
  case searchActive  // 搜索活动
  case activeShare(active: ActiveInfo)  // 活动分享
  case createPost  // 创建帖子
  case webView(url: String, title: String?)  // 网页视图
  case community  // 社区
  case activeCenter  // 活动中心
  case reviewCenter  // 审核中心
  case productShow  // 产品发布会
  case myProduct  // 我的产品
  case myActive  // 我的活动
  case joinedActive  // 参与的活动
  case promotion  // 促销码
  case selectChat  // 选择群聊
  case mindChat(agents: [Agent])  // 聊天室
  case messageCenter  // 消息中心

  static func isWhiteListRoute(to: GeneralRouterDestination) -> Bool {
    switch to {
    case .login, .emailLogin:
      return true
    default:
      return false
    }
  }
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
    case let .submitActiveReview(active, mode, userId):
      SubmitActiveReviewView(active: active, mode: mode, userId: userId)
    case let .registration(active):
      RegistrationView(active: active)
    case .searchActive:
      SearchActiveView()
    case let .activeShare(active):
      ActiveShareView(active: active)
    case .createPost:
      CreatePostView()
    case let .webView(url, title):
      WebView(url: url, title: title)
    case .community:
      CommunityView()
    case .activeCenter:
      ActiveHomeView()
    case .reviewCenter:
      ReviewView()
    case .productShow:
      ProductShowView()
    case .myProduct:
      MyProductsView()
    case .myActive:
      MyActivesView()
    case .joinedActive:
      JoinedActiveView()
    case .promotion:
      PromotionView()
    case .selectChat:
      SelectChatView()
    case let .mindChat(agents):
      MindView(agents: agents)
    case .messageCenter:
      NotificationView()
    }
  }
}
