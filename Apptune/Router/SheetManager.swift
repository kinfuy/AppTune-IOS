import SwiftUI

struct SheetConfig {
  var fullScreen: Bool
  var dismissible: Bool
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

  case activeShare(active: ActiveInfo)

  var id: String {
    switch self {
    case .appStoreSearch: return "appStoreSearch"
    case .activityTemplates: return "activityTemplates"
    case .activityPreview: return "activityPreview"
    case .imagePicker: return "imagePicker"
    case .activeShare: return "activeShare"
    case .imageShare: return "imageShare"
    }
  }

  func config() -> SheetConfig {
    switch self {
    case .imageShare:
      return SheetConfig(fullScreen: false, dismissible: true)
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
    case let .activeShare(active):
      return AnyView(ActiveShareView(active: active))
    case let .imageShare(shareImage, title, onSave):
      return AnyView(ImageShareSheet(shareImage: shareImage, title: title, onSave: onSave))
    }
  }
}

struct SheetItem: Identifiable {
  let id = UUID()
  let type: SheetType
  let config: SheetConfig

  // 关闭时自动触发回调
  func handleClose() {
    type.onClose?()
  }
}

@MainActor
class SheetManager: ObservableObject {
  static let shared = SheetManager()

  @Published private(set) var sheetStack: [SheetItem] = []

  var isPresented: Bool {
    !sheetStack.isEmpty
  }

  var presentedSheet: SheetType? {
    sheetStack.last?.type
  }

  var currentConfig: SheetConfig? {
    sheetStack.last?.config
  }

  // 判断当前显示的 sheet 是否是全屏
  var hasFullScreenSheet: Bool {
    sheetStack.last?.config.fullScreen == true
  }

  // 判断当前显示的 sheet 是否是非全屏
  var hasNormalSheet: Bool {
    sheetStack.last?.config.fullScreen == false
  }

  var dismissible: Bool {
    sheetStack.last?.config.dismissible == false
  }

  func show(_ sheet: SheetType) {
    let config = sheet.config()
    let sheetItem = SheetItem(type: sheet, config: config)

    withAnimation {
      sheetStack.append(sheetItem)
    }
  }

  func close() {
    if let lastSheet = sheetStack.last {
      lastSheet.handleClose()
      withAnimation {
        sheetStack.removeLast()
      }
    }
  }

  func closeAll() {
    for sheet in sheetStack.reversed() {
      sheet.handleClose()
    }
    withAnimation {
      sheetStack.removeAll()
    }
  }

  @ViewBuilder
  func buildSheetView() -> some View {
    if let sheet = presentedSheet {
      ZStack {
        sheet.view

        if NoticeManager.shared.isNotice && isPresented {
          NoticeManager.shared.buildNoticeView(notice: NoticeManager.shared.currentNotice!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.01))
            .ignoresSafeArea()
            .transition(.opacity)
        }
      }
    }
  }
}
