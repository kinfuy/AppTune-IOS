//
//  LoginView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/8.
//

import AuthenticationServices
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{
  static let shared = AppDelegate()
  var onLoginSuccess: ((String, String, String) -> Void)?
  var onLoginError: (() -> Void)?

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      let userIdentifier = appleIDCredential.user

      // 获取已保存的邮箱
      let savedEmail = UserDefaults.standard.string(forKey: "apple_\(userIdentifier)_email") ?? ""
      let savedName = UserDefaults.standard.string(forKey: "apple_\(userIdentifier)_name") ?? ""

      // 如果是首次登录，保存用户信息
      if let email = appleIDCredential.email, !email.isEmpty {
        UserDefaults.standard.set(email, forKey: "apple_\(userIdentifier)_email")

        let fullName = [
          appleIDCredential.fullName?.givenName,
          appleIDCredential.fullName?.familyName,
        ].compactMap { $0 }.joined(separator: " ")

        let name = fullName.isEmpty ? "用户\(String(email.prefix(4)))" : fullName
        UserDefaults.standard.set(name, forKey: "apple_\(userIdentifier)_name")

        onLoginSuccess?(userIdentifier, email, name)
      }
      // 使用保存的信息
      else if !savedEmail.isEmpty {
        onLoginSuccess?(userIdentifier, savedEmail, savedName)
      }
      // 没有邮箱信息，无法登录
      else {
        onLoginError?()
      }
    }
  }

  func authorizationController(
    controller: ASAuthorizationController, didCompleteWithError error: Error
  ) {
    onLoginError?()
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else {
      fatalError("无法找到窗口")
    }
    return window
  }
}

struct LoginView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var userService: UserService
  @Default(\.isAgreeMent) var isAgree: Bool
  @State private var isLoading = false

  func appleAuthLogin() {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = AppDelegate.shared
    authorizationController.presentationContextProvider = AppDelegate.shared

    // 设置回调
    AppDelegate.shared.onLoginSuccess = { userId, email, name in
      Task {
        do {
          let loading = router.openNotice(
            open: .toast(Toast(msg: "登录中...", autoClose: false, loading: true))
          )

          let response = try await UserAPI.shared.sign(
            email: email,
            password: "123456",
            code: "000000"
          )

          // 使用新的 UserService 登录方法
          userService.login(response: response)

          router.closeNotice(id: loading)
          router.popToTabBar(true)

        } catch {
          isLoading = false
        }
      }
    }

    AppDelegate.shared.onLoginError = {
      router.openNotice(open: .toast(Toast(msg: "Apple 登录失败，请使用邮箱登录")))
      isLoading = false
    }

    authorizationController.performRequests()
  }

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Text("跳过")
          .color(.gray)
          .onTapGesture {
            Tap.shared.play(.light)
            router.popToTabBar()
          }
      }
      .padding(.horizontal)

      VStack {
        Image("logo")
          .resizable()
          .frame(width: 148, height: 148)
        Text("AppTune")
          .font(.system(size: 28))
          .fontWeight(.medium)
      }
      .frame(height: UIScreen.main.bounds.height * 0.38)

      Spacer()

      Group {
        HStack {
          SFSymbol.email
          Text("邮箱登录")
        }
        .primaryButton()
        .onTapGesture {
          if self.isAgree {
            router.navigate(to: .emailLogin)
          } else {
            router.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
          }
        }

        HStack {
          Image("apple")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.black)
            .frame(width: 24, height: 24)
          Text("通过 Apple 登录")
        }
        .buttonStyle(Color(hex: "#f4f4f4"), .black)
        .onTapGesture {
          if isLoading { return }
          if self.isAgree {
            isLoading = true
            self.appleAuthLogin()
          } else {
            router.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
          }
        }
      }
      .frame(width: UIScreen.main.bounds.width * 0.72, height: 48)
      .padding(.bottom, 8)

      // 用户协议部分
      AgreementView(isAgree: $isAgree)
        .padding(.vertical)
    }
    .navigationBarBackButtonHidden()
  }
}

// 抽取用户协议视图为单独的组件
struct AgreementView: View {
  @Binding var isAgree: Bool

  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $isAgree) {
          Text("")
        }.toggleStyle(.square)

        Text("我已经同意")
        Text("《用户协议》")
          .foregroundColor(Color(hex: "#555555"))
        Text("和")
        Text("《隐私协议》")
          .foregroundColor(Color(hex: "#555555"))
      }
      VStack {
        Text("《儿童/青少年个人信息保护规则》")
          .foregroundColor(Color(hex: "#555555"))
      }
    }
    .font(.system(size: 12))
    .foregroundColor(.gray)
  }
}

#Preview {
  LoginView()
    .environmentObject(AppState())
    .environmentObject(Router())
}

#if canImport(HotSwiftUI)
  @_exported import HotSwiftUI
#elseif canImport(Inject)
  @_exported import Inject
#else
  // This code can be found in the Swift package:
  // https://github.com/johnno1962/HotSwiftUI

  #if DEBUG
    import Combine

    private var loadInjectionOnce: () = {
      guard objc_getClass("InjectionClient") == nil else {
        return
      }
      #if os(macOS) || targetEnvironment(macCatalyst)
        let bundleName = "macOSInjection.bundle"
      #elseif os(tvOS)
        let bundleName = "tvOSInjection.bundle"
      #elseif os(visionOS)
        let bundleName = "xrOSInjection.bundle"
      #elseif targetEnvironment(simulator)
        let bundleName = "iOSInjection.bundle"
      #else
        let bundleName = "maciOSInjection.bundle"
      #endif
      let bundlePath = "/Applications/InjectionIII.app/Contents/Resources/" + bundleName
      guard let bundle = Bundle(path: bundlePath), bundle.load() else {
        return print(
          """
          ⚠️ Could not load injection bundle from \(bundlePath). \
          Have you downloaded the InjectionIII.app from either \
          https://github.com/johnno1962/InjectionIII/releases \
          or the Mac App Store?
          """)
      }
    }()

    public let injectionObserver = InjectionObserver()

    public class InjectionObserver: ObservableObject {
      @Published var injectionNumber = 0
      var cancellable: AnyCancellable? = nil
      let publisher = PassthroughSubject<Void, Never>()
      init() {
        cancellable = NotificationCenter.default.publisher(
          for:
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION")
        )
        .sink { [weak self] change in
          self?.injectionNumber += 1
          self?.publisher.send()
        }
      }
    }

    extension SwiftUI.View {
      public func eraseToAnyView() -> some SwiftUI.View {
        _ = loadInjectionOnce
        return AnyView(self)
      }
      public func enableInjection() -> some SwiftUI.View {
        return eraseToAnyView()
      }
      public func loadInjection() -> some SwiftUI.View {
        return eraseToAnyView()
      }
      public func onInjection(bumpState: @escaping () -> Void) -> some SwiftUI.View {
        return
          self
          .onReceive(injectionObserver.publisher, perform: bumpState)
          .eraseToAnyView()
      }
    }

    @available(iOS 13.0, *)
    @propertyWrapper
    public struct ObserveInjection: DynamicProperty {
      @ObservedObject private var iO = injectionObserver
      public init() {}
      public private(set) var wrappedValue: Int {
        get { 0 }
        set {}
      }
    }
  #else
    extension SwiftUI.View {
      @inline(__always)
      public func eraseToAnyView() -> some SwiftUI.View { return self }
      @inline(__always)
      public func enableInjection() -> some SwiftUI.View { return self }
      @inline(__always)
      public func loadInjection() -> some SwiftUI.View { return self }
      @inline(__always)
      public func onInjection(bumpState: @escaping () -> Void) -> some SwiftUI.View {
        return self
      }
    }

    @available(iOS 13.0, *)
    @propertyWrapper
    public struct ObserveInjection {
      public init() {}
      public private(set) var wrappedValue: Int {
        get { 0 }
        set {}
      }
    }
  #endif
#endif
