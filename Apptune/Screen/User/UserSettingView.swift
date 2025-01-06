//
//  UserSettingView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/19.
//

import SwiftUI

struct UserSettingView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var userService: UserService
  var title: String = ""

  var body: some View {
    VStack {
      VStack {
        HStack {
          Text("账号与安全")
          Spacer()
          SFSymbol.rightArrow.color(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          Tap.shared.play(.light)
          router.navigate(to: .accountSetting)
        }
        .padding(.top, 24)
        HStack {
          Text("系统设置")
          Spacer()
          SFSymbol.rightArrow.color(.gray)
        }
        .padding(.top, 24)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .background(.white)
      .cornerRadius(16)
      .padding(.bottom, 8)
      VStack {
        HStack {
          Text("意见反馈")
          Spacer()
          SFSymbol.rightArrow.color(.gray)
        }
        .padding(.top, 24)
        HStack {
          Text("使用帮助")
          Spacer()
          SFSymbol.rightArrow.color(.gray)
        }
        .padding(.top, 24)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .background(.white)
      .cornerRadius(16)
      .padding(.bottom, 8)
      VStack {
        HStack {
          Text("关于作者")
          Spacer()
          SFSymbol.rightArrow.color(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          router.navigate(to: .aboutAuthor)
        }
        .padding(.top, 24)
        HStack {
          Text("关于 AppTune")
          Spacer()
          HStack {
            Text("V\(appState.currentVersion)")
              .font(.system(size: 14))
            SFSymbol.rightArrow.color(.gray)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          appState.checkForUpdate(ignoreSkin: true)
        }

        .padding(.top, 24)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .background(.white)
      .cornerRadius(16)
      .padding(.bottom, 12)
      Text("退出登录")
        .buttonStyle(.black)
        .frame(height: 38)
        .onTapGesture {
          Tap.shared.play(.light)
          notice.open(
            open: .confirm(
              Confirm(
                title: "确认退出登录？",
                onSuccess: {
                  Tap.shared.play(.light)
                  userService.logout()
                  router.navigate(to: .login)
                })))
        }
      Spacer()
    }
    .padding()
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("设置")
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
    UserSettingView()
      .environmentObject(Router())
      .environmentObject(AppState())
  }
}
