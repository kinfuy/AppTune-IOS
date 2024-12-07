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
    product: ProductInfo?,
    title: String,
    description: String,
    images: [String],
    limit: Int?,
    endAt: Date?,
    isAutoEnd: Bool,
    publishMode: PublishMode
  )

  var id: String {
    switch self {
    case .appStoreSearch: return "appStoreSearch"
    case .activityTemplates: return "activityTemplates"
    case .activityPreview: return "activityPreview"
    }
  }

  func config() -> SheetConfig {
    switch self {
    case .appStoreSearch:
      return SheetConfig(
        fullScreen: false,
        dismissible: true
      )
    case .activityTemplates:
      return SheetConfig(
        fullScreen: false,
        dismissible: true
      )
    case .activityPreview:
      return SheetConfig(
        fullScreen: false,
        dismissible: true
      )
    }
  }

  // 获取关闭回调
  var onClose: (() -> Void)? {
    switch self {
    case .appStoreSearch(_, let onCancel):
      return onCancel
    case .activityTemplates(_, let onCancel):
      return onCancel
    case .activityPreview(_, _, _, _, _, _, _, _):
      return nil
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

  func show(_ sheet: SheetType) {
    let config = sheet.config()
    let sheetItem = SheetItem(type: sheet, config: config)
    sheetStack.append(sheetItem)
  }

  func close() {
    if let lastSheet = sheetStack.last {
      lastSheet.handleClose()
      sheetStack.removeLast()
    }
  }

  func closeAll() {
    // 从后往前依次关闭
    sheetStack.reversed().forEach { sheet in
      sheet.handleClose()
    }
    sheetStack.removeAll()
  }

  @ViewBuilder
  func buildSheetView() -> some View {
    if let sheet = presentedSheet {
      ZStack {
        switch sheet {
        case .appStoreSearch(let onSubmit, let onCancel):
          AppStoreSearchSheet(onSubmit: onSubmit, onCancel: onCancel)
        case .activityTemplates(let onSelect, let onCancel):
          ActivityTemplatesSheet(onSelect: onSelect, onCancel: onCancel)
        case .activityPreview(
          let product, let title, let description, let images, let limit, let endAt, let isAutoEnd,
          let publishMode):
          ActivityPreviewSheet(
            product: product, title: title, description: description, images: images, limit: limit,
            endAt: endAt, isAutoEnd: isAutoEnd, publishMode: publishMode)
        }

        if NoticeManager.shared.isNotice && SheetManager.shared.isPresented {
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
