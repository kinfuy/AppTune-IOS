//
//  EmailLoginView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//

import AuthenticationServices
import Security
import SwiftUI

struct EmailLoginView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var userService: UserService

  @State private var email: String = ""
  @State private var code: String = ""
  @State private var password: String = ""
  @State private var isLoginEmail = false  // 邮箱验证

  @State private var count: Int = 60
  @State private var isTimeStart: Bool = false
  @State private var isLoading: Bool = false

  func validata() -> Bool {
    if email.isEmpty {
      notice.open(open: .toast("请输入邮箱"))
      return false
    }
    if isLoginEmail {
      if code.isEmpty && password.isEmpty {
        notice.open(open: .toast("请输入验证码和密码"))
        return false
      }
    } else {
      if password.isEmpty {
        notice.open(open: .toast("请输入密码"))
        return false
      }
    }
    return true
  }

  func initTimer() {
    isTimeStart = true
    count = 60
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      if self.count > 0 {
        self.count -= 1
      } else {
        timer.invalidate()
        isTimeStart = false
      }
    }
  }

  var body: some View {
    VStack {
      VStack {
        Group {
          VStack {
            HStack {
              Text("邮箱")
                .foregroundColor(.gray)
              Spacer()
            }
            HStack {
              TextField("", text: $email, prompt: Text("输入邮箱登录"))
                .padding(8)
                .background(Color(hex: "#fafafa"))
                .cornerRadius(4)
                .textContentType(.username)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            }
          }
          VStack {
            HStack {
              Text(isLoginEmail ? "新密码" : "密码")
                .foregroundColor(.gray)
              Spacer()
            }

            SecureField("", text: $password, prompt: Text("输入密码"))
              .padding(8)
              .background(Color(hex: "#fafafa"))
              .cornerRadius(4)
              .textContentType(.password)
              .autocapitalization(.none)
              .disableAutocorrection(true)

            if !isLoginEmail {
              HStack {
                Spacer()
              }
              .padding(.top, 4)
            }
          }

          if isLoginEmail {
            VStack {
              HStack {
                Text("验证码")
                  .foregroundColor(.gray)
                Spacer()
              }
              HStack {
                TextField("", text: $code, prompt: Text("输入验证码"))
                  .keyboardType(.numberPad)
                if isTimeStart {
                  Text("\(self.count.description)s")
                } else {
                  Text("获取验证码")
                    .color(.theme)
                    .onTapGesture {
                      Tap.shared.play(.light)
                      if email.isEmpty {
                        notice.open(open: .toast(Toast(msg: "请先填写邮箱")))
                        return
                      }

                      let loading = notice.open(
                        open: .toast(
                          Toast(
                            msg: "请求中",
                            autoClose: false,
                            loading: true,
                            clickMask: false
                          )
                        )
                      )

                      Task {
                        do {
                          try await API.sendCode(email: email)
                          notice.close(id: loading)
                          initTimer()
                        } catch {
                          notice.close(id: loading)
                        }
                      }
                    }
                }
              }
              .padding(8)
              .background(Color(hex: "#fafafa"))
              .cornerRadius(4)
            }
          }

        }
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      .padding(.bottom, 12)
      Text(!isLoginEmail ? "登录" : "登录/注册")
        .loadingButton(loading: isLoading)
        .primaryButton()
        .frame(height: 42)
        .onTapGesture {
          if isLoading { return }
          Tap.shared.play(.light)

          if validata() {
            isLoading = true
            Task {
              do {
                let response = try await API.sign(
                  email: email,
                  password: password,
                  code: code
                )

                userService.login(response: response)

                isLoading = false
                router.toTabBar(.home)
              } catch {
                isLoading = false
              }
            }
          }
        }
      HStack {
        Spacer()
        Text(isLoginEmail ? "我有账号, 密码登录！" : "忘记密码/没有账号？")
          .foregroundColor(.gray)
          .font(.system(size: 14))
          .onTapGesture {
            Tap.shared.play(.light)
            isLoginEmail = !isLoginEmail
            code = ""
            password = ""
            isLoading = false
          }
      }
      .padding(.top, 8)
      Spacer()
    }
    .padding(24)
    .navigationBarBackButtonHidden()
    .navigationBarTitle("邮箱登录")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: {
          router.back()
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
            }
          }
          .foregroundStyle(Color(hex: "#333333"))
        }
      )
    )
  }
}
