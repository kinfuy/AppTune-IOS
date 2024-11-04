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

  var id: String {
    switch self {
    case .appStoreSearch: return "appStoreSearch"
    }
  }

  func config() -> SheetConfig {
    switch self {
    case .appStoreSearch:
      return SheetConfig(
        fullScreen: false,
        dismissible: true
      )
    }
  }
}

struct SheetItem: Identifiable {
  let id = UUID()
  let type: SheetType
  let config: SheetConfig
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
      switch lastSheet.type {
      case .appStoreSearch(_, let onCancel):
        onCancel?()
      }
      sheetStack.removeLast()
    }
  }

  func closeAll() {
    // 从后往前依次关闭
    if let currentSheet = presentedSheet {
      switch currentSheet {
      case .appStoreSearch(_, let onCancel):
        onCancel?()
      }
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
