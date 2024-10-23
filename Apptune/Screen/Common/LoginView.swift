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
