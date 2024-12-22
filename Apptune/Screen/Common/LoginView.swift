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
  var onLoginSuccess: ((String, String?, String?) -> Void)?
  var onLoginError: (() -> Void)?

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      // 获取身份令牌
      guard let identityToken = appleIDCredential.identityToken,
            let identityTokenString = String(data: identityToken, encoding: .utf8) else {
        onLoginError?()
        return
      }

      // 组合姓名
      let name = [
        appleIDCredential.fullName?.familyName,
        appleIDCredential.fullName?.givenName
      ].compactMap { $0 }.joined(separator: "")

      // 直接传递 Apple 提供的原始信息给服务器
      onLoginSuccess?(
        identityTokenString,
        appleIDCredential.email,
        name.isEmpty ? nil : name
      )
    }
  }

  func authorizationController(
    controller: ASAuthorizationController, didCompleteWithError error: Error
  ) {
    print("Apple 登录错误:", error.localizedDescription)
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
  @EnvironmentObject var notice: NoticeManager
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
    AppDelegate.shared.onLoginSuccess = { idToken, email, name in
      Task {
        do {
          let loading = notice.openNotice(
            open: .toast(Toast(msg: "登录中...", autoClose: false, loading: true))
          )

          // 将用户信息传递给服务器
          let response = try await API.signApple(
            idToken: idToken,
            email: email,
            name: name // 直接传递组合后的姓名
          )

          userService.login(response: response)
          notice.closeNotice(id: loading)
          router.toTabBar(.home)

        } catch {
          isLoading = false
        }
      }
    }

    AppDelegate.shared.onLoginError = {
      notice.openNotice(open: .toast("Apple 授权失败"))
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
            router.toTabBar(.home)
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
            notice.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
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
            notice.openNotice(open: .agreement(AGGREEMENT_NOTICE_ID))
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
