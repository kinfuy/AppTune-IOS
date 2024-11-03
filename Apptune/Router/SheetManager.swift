import SwiftUI

struct SheetConfig {
    var fullScreen: Bool
    var dismissible: Bool
    var onDismiss: (() -> Void)?
}

enum SheetType: Identifiable {
    case appStoreSearch
    // 添加其他 sheet 类型...

    var id: String {
        switch self {
        case .appStoreSearch: return "appStoreSearch"
        }
    }

    func config(onDismiss: (() -> Void)? = nil) -> SheetConfig {
        switch self {
        case .appStoreSearch:
            return SheetConfig(
                fullScreen: false,
                dismissible: true,
                onDismiss: onDismiss
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

    func show(_ sheet: SheetType, onDismiss: (() -> Void)? = nil) {
        let config = sheet.config(onDismiss: onDismiss)
        let sheetItem = SheetItem(type: sheet, config: config)
        sheetStack.append(sheetItem)
    }

    func close() {
        if let lastSheet = sheetStack.last {
            lastSheet.config.onDismiss?()
            sheetStack.removeLast()
        }
    }

    func closeAll() {
        // 从后往前依次调用 onDismiss
        for sheet in sheetStack.reversed() {
            sheet.config.onDismiss?()
        }
        sheetStack.removeAll()
    }

    @ViewBuilder
    func buildSheetView() -> some View {
        if let sheet = presentedSheet {
            ZStack { // 添加 ZStack 来处理多层视图
                switch sheet {
                case .appStoreSearch:
                    AppStoreSearchSheet()
                }
                // 在 sheet 内部添加 notice 层
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
