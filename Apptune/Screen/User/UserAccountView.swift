//
//  UserSettingView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/19.
//

import SwiftUI

struct UserAccountView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var userService: UserService

  var body: some View {
    VStack {
      VStack {
        HStack {
          Text("用户名")
          Spacer()
          Text(attributedString(str: userService.user.name))
            .foregroundColor(.gray)
        }
        .padding(.top, 24)
        HStack {

        }
        HStack {
          Text("邮箱")
          Spacer()
          Text(attributedString(str: userService.user.email))
            .foregroundColor(.gray)
        }
        .padding(.top, 24)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .background(.white)
      .cornerRadius(16)
      .padding(.bottom, 8)
      Text("注销账号")
        .foregroundColor(.red)
        .buttonStyle(.white)
        .frame(height: 38)
        .onTapGesture {
          Tap.shared.play(.light)
          router.navigate(to: .login)
        }
      Spacer()
    }
    .padding()
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("账号设置")
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
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

#Preview {
  NavigationStack {
    UserAccountView()
      .environmentObject(Router())
      .environmentObject(AppState())
  }
}
