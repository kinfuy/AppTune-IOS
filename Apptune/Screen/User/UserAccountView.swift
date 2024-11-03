//
//  UserSettingView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/19.
//

import SwiftUI

struct UserAccountView: View {
  @EnvironmentObject var router: Router
    @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var userService: UserService

  var body: some View {
    VStack {
      VStack {

        HStack {
          Text("邮箱")
          Spacer()
          Text(attributedString(str: userService.profile.email))
            .foregroundColor(.gray)
        }
        .padding(.top, 24)

        if let mobile = userService.profile.mobile {
          HStack {
            Text("手机")
            Spacer()
            Text(attributedString(str: mobile))
              .foregroundColor(.gray)
          }
          .padding(.top, 24)
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .background(.white)
      .cornerRadius(16)
      .padding(.bottom, 8)

      Button(action: {
        notice.openNotice(
          open: .confirm(
            Confirm(
              title: "确认注销",
              desc: "注销将删除该账号私有数据？",
              onSuccess: {
                userService.logout()
                router.navigate(to: .login)
              }
            )))
      }) {
        Text("注销账号")
          .foregroundColor(.red)
          .frame(maxWidth: .infinity)
          .frame(height: 38)
          .background(.white)
          .cornerRadius(8)
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
  }
}

#Preview {
  NavigationStack {
    UserAccountView()
      .environmentObject(Router())
      .environmentObject(AppState())
  }
}
