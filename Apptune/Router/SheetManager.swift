import Combine
import SheetKit
import SwiftUI

struct SheetConfig {
  var fullScreen: Bool
  var dismissible: Bool
  var height: CGFloat?  // 这里的值应该是 0-1 之间的比例
  var showDragIndicator: Bool?
}

enum SheetType: Identifiable {
  case appStoreSearch(
    onSubmit: ((AppSearchInfo) -> Void)? = nil,
    onCancel: (() -> Void)? = nil
  )

  case activityTemplates(
    onSelect: ((ActiveTemplateInfo) -> Void)? = nil,
    onCancel: (() -> Void)? = nil
  )

  case activityPreview(
    active: ActiveInfo
  )

  case imagePicker(
    onSelect: ((UIImage) -> Void)? = nil,
    onCancel: (() -> Void)? = nil
  )

  case imageShare(
    shareImage: UIImage,
    title: String,
    onSave: (() -> Void)? = nil
  )

  case preCodePicker(
    productId: String,
    selectedGroups: [String],
    onSelect: ((_ groups: [String]) -> Void)? = nil,
    onCancel: (() -> Void)? = nil,
    config: ProCodeSheetConfig
  )

  case linkPicker(
    onConfirm: ((_ link: PostLink) -> Void)? = nil,
    onCancel: (() -> Void)? = nil
  )

  case coinBuy(
    onConfirm: ((_ product: CoinProduct) -> Void)? = nil,
    onCancel: (() -> Void)? = nil
  )

  case createType

  var id: String {
    switch self {
    case .appStoreSearch: return "appStoreSearch"
    case .activityTemplates: return "activityTemplates"
    case .activityPreview: return "activityPreview"
    case .imagePicker: return "imagePicker"
    case .imageShare: return "imageShare"
    case .preCodePicker: return "preCodePicker"
    case .linkPicker: return "linkPicker"
    case .coinBuy: return "coinBuy"
    case .createType: return "createType"
    }
  }

  func config() -> SheetConfig {
    switch self {
    case .imagePicker:
      return SheetConfig(fullScreen: true, dismissible: true)
    case .imageShare:
      return SheetConfig(fullScreen: false, dismissible: true)
    case .preCodePicker:
      return SheetConfig(fullScreen: false, dismissible: true, height: 0.68)
    case .linkPicker:
      return SheetConfig(fullScreen: false, dismissible: true, height: 0.5)
    case .coinBuy:
      return SheetConfig(fullScreen: false, dismissible: true, height: 0.5)
    case .createType:
      return SheetConfig(
        fullScreen: false, dismissible: true, height: 0.68, showDragIndicator: true)
    case .activityPreview:
      return SheetConfig(fullScreen: false, dismissible: true, showDragIndicator: true)
    default:
      return SheetConfig(fullScreen: false, dismissible: true)
    }
  }

  // 获取关闭回调
  var onClose: (() -> Void)? {
    switch self {
    case let .appStoreSearch(_, onCancel):
      return onCancel
    case let .activityTemplates(_, onCancel):
      return onCancel
    case let .imagePicker(_, onCancel):
      return onCancel
    case let .linkPicker(_, onCancel):
      return onCancel
    case let .coinBuy(_, onCancel):
      return onCancel
    case .createType:
      return nil
    default:
      return nil
    }
  }

  var view: AnyView {
    switch self {
    case .appStoreSearch(let onSubmit, let onCancel):
      return AnyView(AppStoreSearchSheet(onSubmit: onSubmit, onCancel: onCancel))
    case .activityTemplates(let onSelect, let onCancel):
      return AnyView(ActivityTemplatesSheet(onSelect: onSelect, onCancel: onCancel))
    case let .activityPreview(active):
      return AnyView(ActivityPreviewSheet(active: active))
    case .imagePicker(let onSelect, let onCancel):
      return AnyView(ImageSheet(onSelect: onSelect, onCancel: onCancel))
    case let .imageShare(shareImage, title, onSave):
      return AnyView(ImageShareSheet(shareImage: shareImage, title: title, onSave: onSave))
    case .preCodePicker(let productId, let selectedGroups, let onSelect, let onCancel, let config):
      return AnyView(
        PreCodePickerSheet(
          productId: productId,
          selectedGroups: selectedGroups,
          onSelect: onSelect,
          onCancel: onCancel,
          config: config
        )
      )
    case .linkPicker(let onConfirm, let onCancel):
      return AnyView(Link_Sheet(onConfirm: onConfirm, onCancel: onCancel))
    case .coinBuy(let onConfirm, let onCancel):
      return AnyView(CoinBuy_Sheet(onConfirm: onConfirm, onCancel: onCancel))
    case .createType:
      return AnyView(CreateTypeSheet())
    }
  }
}

struct SheetItem: Identifiable, Equatable {
  let id = UUID()
  let type: SheetType
  let config: SheetConfig

  static func == (lhs: SheetItem, rhs: SheetItem) -> Bool {
    lhs.id == rhs.id
  }

  // 关闭时自动触发回调
  func handleClose() {
    type.onClose?()
  }
}

@MainActor
class SheetManager: ObservableObject {
  static let shared = SheetManager()

  @Published var sheetStack = [SheetItem]()
  @Published private var noticeUpdateTrigger = false
  @Published var forceUpdate = UUID()

  private var cancellables = Set<AnyCancellable>()

  init() {
    // 合并观察两个状态的变化
    Publishers.Merge(
      NoticeManager.shared.$currentNotice,
      NoticeManager.shared.$_isNotice.map { _ in NoticeManager.shared.currentNotice }
    )
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
      self?.forceUpdate = UUID()
    }
    .store(in: &cancellables)
  }

  // 存储环境变量
  private var appState: AppState?
  private var router: Router?
  private var notice: NoticeManager?
  private var userService: UserService?
  private var sheet: SheetManager?
  private var productService: ProductService?
  private var promotionService: PromotionService?
  private var activeService: ActiveService?
  private var tagService: TagService?
  private var notificationService: NotificationService?
  private var communityService: CommunityService?

  // 设置环境变量的方法
  func setEnvironmentObjects(
    appState: AppState,
    router: Router,
    notice: NoticeManager,
    userService: UserService,
    sheet: SheetManager,
    productService: ProductService,
    promotionService: PromotionService,
    activeService: ActiveService,
    tagService: TagService,
    notificationService: NotificationService,
    communityService: CommunityService
  ) {
    self.appState = appState
    self.router = router
    self.notice = notice
    self.userService = userService
    self.sheet = self
    self.productService = productService
    self.promotionService = promotionService
    self.activeService = activeService
    self.tagService = tagService
    self.notificationService = notificationService
    self.communityService = communityService
  }

  // 注入环境变量的私有方法
  private func injectEnvironmentObjects<T: View>(_ view: T) -> some View {
    view
      .environmentObject(self.appState ?? AppState.shared)
      .environmentObject(self.router ?? Router.shared)
      .environmentObject(self.notice ?? NoticeManager.shared)
      .environmentObject(self.userService ?? UserService())
      .environmentObject(self.sheet ?? SheetManager.shared)
      .environmentObject(self.productService ?? ProductService())
      .environmentObject(self.promotionService ?? PromotionService())
      .environmentObject(self.activeService ?? ActiveService())
      .environmentObject(self.tagService ?? TagService())
      .environmentObject(self.notificationService ?? NotificationService())
      .environmentObject(self.communityService ?? CommunityService())
  }

  func show(_ sheet: SheetType) {
    let config = sheet.config()
    sheetStack.append(SheetItem(type: sheet, config: config))

    let bottomSheetConfig = SheetKit.BottomSheetConfiguration(
      detents: (config.height != nil)
        ? [
          UISheetPresentationController.Detent.custom(resolver: { _ in
            config.height! * UIScreen.main.bounds.height
          })
        ] : [.large()],
      largestUndimmedDetentIdentifier: nil,
      prefersGrabberVisible: config.showDragIndicator ?? false,
      prefersScrollingExpandsWhenScrolledToEdge: true,
      prefersEdgeAttachedInCompactHeight: true,
      widthFollowsPreferredContentSizeWhenEdgeAttached: true,
      preferredCornerRadius: nil
    )

    SheetKit().present(
      with: config.fullScreen ? .fullScreenCover : .customBottomSheet,
      onDisappear: {
        self.sheetStack.removeLast()
      },
      configuration: bottomSheetConfig
    ) {
      ZStack {
        // Sheet 内容
        injectEnvironmentObjects(sheet.view)
          .interactiveDismissDisabled(!config.dismissible)

        // Notice 层
        NoticeOverlay(notice: notice)
          .environmentObject(self.appState ?? AppState.shared)
          .environmentObject(self.router ?? Router.shared)
          .environmentObject(self.notice ?? NoticeManager.shared)
          .environmentObject(self.userService ?? UserService())
          .environmentObject(self.sheet ?? SheetManager.shared)
          .environmentObject(self.productService ?? ProductService())
          .environmentObject(self.promotionService ?? PromotionService())
          .environmentObject(self.activeService ?? ActiveService())
          .environmentObject(self.tagService ?? TagService())
          .environmentObject(self.notificationService ?? NotificationService())
          .environmentObject(self.communityService ?? CommunityService())
          .id(forceUpdate)  // 使用 UUID 强制更新
      }
    }
  }

  func close() {
    SheetKit().dismiss()
  }

  func closeAll() {
    SheetKit().dismissAllSheets()
  }

  func hasSheet() -> Bool {
    return sheetStack.count > 0
  }
}

// 将 Notice 层抽取为单独的视图组件
private struct NoticeOverlay: View {
  let notice: NoticeManager?
  @ObservedObject private var noticeManager = NoticeManager.shared

  var body: some View {
    Group {
      if let currentNotice = noticeManager.currentNotice {
        noticeManager.buildNoticeView(notice: currentNotice)
          .background(Color.black.opacity(0.01))
          .ignoresSafeArea()
          .transition(.opacity)
          .zIndex(999)  // 添加 zIndex 确保在最上层
      }
    }
  }
}
