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

enum NoticeDestiantion {
  case version(String)  // 版本更新检查
  case agreement(String)  // 用户协议同意
  case toast(Toast)  // 常规信息提示
  case loading(Toast)  // 加载
  case confirm(Confirm)  // 确认弹窗
  case message(Message)  // 新增 message 类型

  var id: String {
    switch self {
    case let .agreement(id): id
    case let .toast(ctx): ctx.id.uuidString
    case let .loading(ctx): ctx.id.uuidString
    case let .version(id): id
    case let .confirm(ctx): ctx.id.uuidString
    case let .message(ctx): ctx.id.uuidString
    }
  }

  var config: NoticeConfig {
    switch self {
    case .version:
      NoticeConfig(maskHiden: false, mask: true)
    case .toast:
      NoticeConfig(maskHiden: false, mask: false)
    case .loading:
      NoticeConfig(maskHiden: true, mask: false)
    case .message:
      NoticeConfig(maskHiden: false, mask: false)
    default:
      NoticeConfig(maskHiden: true, mask: true)
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
}

@MainActor
class NoticeManager: ObservableObject {
  static let shared = NoticeManager()
  @Published var noticeStack: [NoticeDestiantion] = []
  @Published var currentNotice: NoticeDestiantion?

  var isNotice: Bool {
    return currentNotice != nil
  }

  @discardableResult
  @MainActor
  func openNotice(open: NoticeDestiantion) -> String {
    if case NoticeDestiantion.toast = open {
      noticeStack = noticeStack.filter {
        if case NoticeDestiantion.toast = $0 {
          return false
        }
        return true
      }
    }

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

  private func popNotice() {
    if let last = noticeStack.last {
      currentNotice = last
    } else {
      currentNotice = nil
    }
  }

  @ViewBuilder
  func buildNoticeView(notice: NoticeDestiantion) -> some View {
    ZStack {
      VStack {}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(notice.config.mask ? .black.opacity(0.58) : .clear)
        .onTapGesture {
          if notice.config.maskHiden {
            self.closeNotice(id: notice.id)
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
      }
    }
    .background(.black.opacity(0.01))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
