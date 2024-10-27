//
//  LoginView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/8.
//

import AuthenticationServices
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppDelegate()

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            print(userIdentifier, fullName ?? "", email ?? "")

            // 在这里处理登录成功，比如存储用户信息或更新界面
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 在这里处理登录错误，比如显示错误信息
        print(error.localizedDescription)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("无法找到窗口")
        }
        return window
    }
}

struct LoginView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: AppState
    @Default(\.isAgreeMent) var isAgree: Bool

    func appleAuthLogin() {
        if #available(iOS 13.0, *) {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = AppDelegate.shared
            authorizationController.presentationContextProvider = AppDelegate.shared
            authorizationController.performRequests()
        }
    }

    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("跳过")
                    .color(.gray)
                    .onTapGesture {
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
//                HStack {
//                    Image("wechat")
//                        .resizable()
//                        .renderingMode(.template)
//                        .foregroundColor(.white)
//                        .frame(width: 22, height: 22)
//                    Text("微信登录")
//                }
//                .primaryButton()
//                .onTapGesture {
//                    if(appState.isAgree){
//                        self.appleAuthLogin()
//                    }else {
//                        router.popToTabBar()
//                    }
//
//                }
                HStack {
                    SFSymbol.email
                    Text("邮箱登录")
                }
                .primaryButton()
                .onTapGesture {
                    if self.isAgree {
                        router.navigate(to: .emailLogin)
                    } else {
                        _ = router.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
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
                    if self.isAgree {
                        self.appleAuthLogin()
                    } else {
                        _ = router.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.72, height: 48)
            .padding(.bottom, 8)
            VStack {
                HStack {
                    Toggle(isOn: self.$isAgree) {
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
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden()
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
        let bundlePath = "/Applications/InjectionIII.app/Contents/Resources/"+bundleName
        guard let bundle = Bundle(path: bundlePath), bundle.load() else {
            return print("""
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
        cancellable = NotificationCenter.default.publisher(for:
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
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
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
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
        get {0} set {}
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
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
    }
}

@available(iOS 13.0, *)
@propertyWrapper
public struct ObserveInjection {
    public init() {}
    public private(set) var wrappedValue: Int {
        get {0} set {}
    }
}
#endif
#endif
