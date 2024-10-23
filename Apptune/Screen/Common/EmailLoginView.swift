//
//  EmailLoginView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//

import SwiftUI

struct EmailLoginView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: AppState

    @State private var email: String = ""
    @State private var code: String = ""
    @State private var password: String = ""
    @State private var isLoginEmail = false // 邮箱验证

    @State private var count: Int = 60
    @State private var isTimeStart: Bool = false
    

    func validata() -> Bool {
        if email == "" {
            return false
        }
        if isLoginEmail && code == "" {
            return false
        }
        if !isLoginEmail && password == "" {
            return false
        }
        return true
    }

    func initTimer() {
        isTimeStart = true
        count = 60
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.count > 0 {
                self.count -= 1
            } else {
                self.count = 60
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
                        }
                    }
                    VStack {
                        HStack {
                            Text(!isLoginEmail ? "密码" : "验证码")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        if !isLoginEmail {
                            TextField("", text: $password, prompt: Text("输入密码"))
                                .padding(8)
                                .background(Color(hex: "#fafafa"))
                                .cornerRadius(4)
                        } else {
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
                                            if email == "" {
                                                _ = router.openNotice(open: .toast(Toast(msg: "请先填写邮箱")))
                                                return
                                            }
                                            Task {
                                                let loading = router.openNotice(
                                                    open: .toast(
                                                        Toast(
                                                            msg: "请求中",
                                                            autoClose: false,
                                                            loading: true,
                                                            clickMask: false
                                                        ))
                                                )
                                                do {
                                                    try await UserAPI.shared.sendCode(email: email)
                                                    router.closeNotice(id: loading)
                                                    DispatchQueue.main.async {
                                                        self.initTimer()
                                                    }
                                                } catch let APIError.serveError(errMsg) {
                                                    router.closeNotice(id: loading)
                                                    _ = router.openNotice(open: .toast(Toast(msg: errMsg)))
                                                } catch {
                                                    router.closeNotice(id: loading)
                                                    let _ = router.openNotice(
                                                        open: .toast(Toast(msg: error.localizedDescription)))
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
                .primaryButton()
                .frame(height: 42)
                .onTapGesture {
                    Tap.shared.play(.light)
                    if validata() {
                    } else {
                        let _ = router.openNotice(open: .toast(Toast(msg: "请完善信息后操作")))
                    }
                }
            HStack {
                Spacer()
                Text(isLoginEmail ? "我有账号, 密码登录" : "忘记密码/没有账号？")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .onTapGesture {
                        Tap.shared.play(.light)
                        isLoginEmail = !isLoginEmail
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
                })
        )
    }
}
