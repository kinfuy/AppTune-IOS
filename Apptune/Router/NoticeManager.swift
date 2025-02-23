import SwiftUI

struct NoticeConfig {
  var maskHiden: Bool
  var mask: Bool
  var blockInteraction: Bool

  static let transparent = NoticeConfig(maskHiden: false, mask: false, blockInteraction: false)
  static let blocking = NoticeConfig(maskHiden: true, mask: true, blockInteraction: true)
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

struct Message {
  var id: UUID = UUID()
  var message: String
  var icon: String?
  var customView: AnyView?
  var position: MessagePosition = .top
  var alignment: MessageAlignment = .center
  var loading: Bool = false
  var time: CGFloat = 1.5
  var autoClose: Bool = true
  var theme: MessageTheme = .dark
}

struct ImagePreview {
  var id: UUID = UUID()
  var url: String
  var imageType: ImageType
}

enum NoticeDestiantion {
  case version(String)  // 版本更新检查
  case agreement(String)  // 用户协议同意
  case toast(Toast)  // 常规信息提示
  case loading(Toast)  // 加载
  case confirm(Confirm)  // 确认弹窗
  case message(Message)  // 新增 message 类型
  case imagePreview(ImagePreview)  // 新增图片预览类型
  case firstProduct(String)  // 添加产品创建引导类型
  case joinSuccess(String)  // 添加报名成功类型

  var id: String {
    switch self {
    case let .agreement(id): id
    case let .toast(ctx): ctx.id.uuidString
    case let .loading(ctx): ctx.id.uuidString
    case let .version(id): id
    case let .confirm(ctx): ctx.id.uuidString
    case let .message(ctx): ctx.id.uuidString
    case let .imagePreview(ctx): ctx.id.uuidString
    case let .firstProduct(id): id
    case let .joinSuccess(id): id
    }
  }

  var config: NoticeConfig {
    switch self {
    case .version, .firstProduct, .joinSuccess:
      NoticeConfig(maskHiden: false, mask: true, blockInteraction: true)
    case .toast, .loading, .message:
      NoticeConfig.transparent
    case .agreement, .confirm:
      NoticeConfig.blocking
    case .imagePreview:
      NoticeConfig(maskHiden: true, mask: true, blockInteraction: true)
    }
  }

  static func toast(_ message: String, autoClose: Bool = true, time: CGFloat = 1.5)
    -> NoticeDestiantion
  {
    return .toast(Toast(msg: message, autoClose: autoClose, time: time))
  }

  static func loading(_ message: String, theme: MessageTheme = .dark) -> NoticeDestiantion {
    return .message(Message(message: message, loading: true, theme: theme))
  }

  static func confirm(
    title: String, desc: String = "", onSuccess: @escaping () -> Void, onCancel: (() -> Void)? = nil
  ) -> NoticeDestiantion {
    return .confirm(Confirm(title: title, desc: desc, onCancel: onCancel, onSuccess: onSuccess))
  }

  static func message(
    _ text: String,
    icon: String? = nil,
    position: MessagePosition = .top,
    alignment: MessageAlignment = .center,
    loading: Bool = false,
    autoClose: Bool = true,
    time: CGFloat = 1.5,
    theme: MessageTheme = .dark
  ) -> NoticeDestiantion {
    return .message(
      Message(
        message: text,
        icon: icon,
        position: position,
        alignment: alignment,
        loading: loading,
        time: time,
        autoClose: autoClose,
        theme: theme
      ))
  }

  static func customMessage(
    _ view: AnyView,
    position: MessagePosition = .top,
    alignment: MessageAlignment = .center,
    autoClose: Bool = true,
    time: CGFloat = 1.5,
    theme: MessageTheme = .dark
  ) -> NoticeDestiantion {
    return .message(
      Message(
        message: "",
        customView: view,
        position: position,
        alignment: alignment,
        time: time,
        autoClose: autoClose,
        theme: theme
      ))
  }

  static func imagePreview(url: String, imageType: ImageType) -> NoticeDestiantion {
    return .imagePreview(ImagePreview(url: url, imageType: imageType))
  }
}

@MainActor
class NoticeManager: ObservableObject {
  static let shared = NoticeManager()
  @Published var noticeStack: [NoticeDestiantion] = []
  @Published var currentNotice: NoticeDestiantion?
  @Published private(set) var _isNotice: Bool = false

  var isNotice: Bool {
    return currentNotice != nil
  }

  @discardableResult
  @MainActor
  func open(open: NoticeDestiantion) -> String {
    if noticeStack.contains(where: { $0.id == open.id }) {
      return open.id
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.noticeStack.append(open)
      withAnimation(.easeIn(duration: 0.38)) {
        self.currentNotice = open
        self._isNotice = true
      }
    }

    if case let NoticeDestiantion.toast(ctx) = open {
      if ctx.autoClose {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(ctx.time)) {
          self.close(id: ctx.id.uuidString)
        }
      }
    }

    return open.id
  }

  @MainActor
  func close(id: String? = nil) {
    if let noticeId = id {
      noticeStack = noticeStack.filter { $0.id != noticeId }
    } else {
      if !noticeStack.isEmpty {
        noticeStack.removeLast()
      }
    }
    popNotice()
  }

  private func popNotice() {
    if let last = noticeStack.last {
      currentNotice = last
      _isNotice = true
    } else {
      currentNotice = nil
      _isNotice = false
    }
  }

  @ViewBuilder
  func buildNoticeView(notice: NoticeDestiantion) -> some View {
    ZStack {
      // 遮罩层
      if notice.config.mask {
        Color.black.opacity(0.58)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .ignoresSafeArea(.all)
          .onTapGesture {
            if notice.config.maskHiden {
              self.close(id: notice.id)
            }
          }
      }

      // Notice 内容
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
      case let .loading(loading):
        Toast_Modal(
          id: loading.id.uuidString,
          messgae: loading.msg,
          time: loading.time,
          loading: true
        )
      case let .confirm(ctx):
        Confirm_Modal(
          id: ctx.id.uuidString,
          titile: ctx.title,
          desc: ctx.desc,
          onSubmit: ctx.onSuccess,
          onCancel: ctx.onCancel ?? {}
        )
      case let .message(msg):
        Message_Modal(
          id: msg.id.uuidString,
          message: msg.message,
          icon: msg.icon,
          customView: msg.customView,
          position: msg.position,
          alignment: msg.alignment,
          loading: msg.loading,
          time: msg.time,
          theme: msg.theme
        )
      case let .imagePreview(preview):
        ImagePreviewView(
          url: preview.url,
          imageType: preview.imageType,
          id: preview.id.uuidString
        )
      case .firstProduct:
        FirshProduct_Modal()
      case .joinSuccess:
        Join_Modal()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    // 只在需要阻止交互的情况下阻止
    .allowsHitTesting(notice.config.blockInteraction)
  }

  func hide(id: String) {
    // 移除指定 id 的消息
  }
}
