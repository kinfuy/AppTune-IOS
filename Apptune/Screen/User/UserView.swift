//
//  UserView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/15.
//

import SwiftUI

struct UserView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var userService: UserService
  @EnvironmentObject var notice: NoticeManager

  var body: some View {
    ZStack {
      VStack {
        HStack(spacing: 16) {
          Group {
            Spacer()
            SFSymbol.set
              .onTapGesture {
                router.navigate(to: .setting)
              }
          }
          .font(.system(size: 20))
        }
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 8) {
            Text(userService.profile.name)
              .font(.title3)
              .fontWeight(.bold)
              .onTapGesture {
                Tap.shared.play(.light)
                DispatchQueue.main.async {
                  router.navigate(to: .userProfile)
                }
              }
            HStack {
              if let role = userService.role {
                Text(role)
                  .font(.system(size: 12))
                  .colorTag(.theme)
              }
            }
            HStack(spacing: 32) {
              VStack(alignment: .leading) {
                Text(userService.stats.follow.description)
                  .font(.system(size: 16))
                Text("关注")
                  .foregroundColor(.gray)
                  .font(.system(size: 12))
              }
              VStack(alignment: .leading) {
                Text(userService.stats.fans.description)
                  .font(.system(size: 16))
                Text("粉丝")
                  .foregroundColor(.gray)
                  .font(.system(size: 12))
              }
            }
          }
          Spacer()
          ImgLoader(userService.profile.avatar)
            .frame(width: 78, height: 78)
            .clipShape(Circle())
            .background(
              Circle()
                .fill(Color.white)
                .frame(width: 88, height: 88)
            )
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 2)
            )
            .onTapGesture {
              Tap.shared.play(.light)
              DispatchQueue.main.async {
                router.navigate(to: .userProfile)
              }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 32)
        HStack(spacing: 24) {
          // 积分卡片部分的更新
          VStack(alignment: .leading, spacing: 12) {
            // 积分标题
            Text("我的积分")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.white.opacity(0.9))
              .padding(.horizontal, 12)
              .padding(.vertical, 4)
              .background(
                Capsule()
                  .fill(.white.opacity(0.15))
              )

            // 积分数值
            Text(userService.stats.coin.description)
              .fontWeight(.heavy)
              .font(.system(size: 36))
              .foregroundColor(.white)
              .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
              .padding(.leading, 4)
          }

          Spacer()

          // 右侧按钮组
          HStack(spacing: 20) {
            // 积分任务按钮
            VStack(spacing: 8) {
              ZStack {
                // 渐变背景
                Circle()
                  .fill(
                    LinearGradient(
                      colors: [.white.opacity(0.25), .white.opacity(0.1)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 52, height: 52)
                  .overlay(
                    Circle()
                      .stroke(.white.opacity(0.2), lineWidth: 1)
                  )

                // 图标
                SFSymbol.task
                  .font(.system(size: 22))
                  .foregroundColor(.white)
              }
              .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

              Text("做任务")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            }
            .onTapGesture {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                router.navigate(to: .coinTasks)
              }
            }

            // 积分商城按钮
            VStack(spacing: 8) {
              ZStack {
                // 渐变背景
                Circle()
                  .fill(
                    LinearGradient(
                      colors: [.white.opacity(0.25), .white.opacity(0.1)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 52, height: 52)
                  .overlay(
                    Circle()
                      .stroke(.white.opacity(0.2), lineWidth: 1)
                  )

                // 图标
                SFSymbol.shop
                  .font(.system(size: 22))
                  .foregroundColor(.white)
              }
              .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

              Text("兑好礼")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            }
            .onTapGesture {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                router.navigate(to: .coinShop)
              }
            }
          }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
          ZStack {
            // 主渐变背景
            LinearGradient(
              colors: [
                Color.orange.opacity(0.68),
                Color.theme,
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )

            // 左上装饰性渐变圆
            Circle()
              .fill(
                LinearGradient(
                  colors: [.theme.opacity(0.48), .clear],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 120)
              .blur(radius: 20)
              .offset(x: -60, y: -30)

            // 右下装饰性渐变圆
            Circle()
              .fill(
                LinearGradient(
                  colors: [.theme.opacity(0.28), .clear],
                  startPoint: .topTrailing,
                  endPoint: .bottomLeading
                )
              )
              .frame(width: 100)
              .blur(radius: 25)
              .offset(x: 80, y: 40)

            // 中间装饰性光晕
            Ellipse()
              .fill(
                RadialGradient(
                  colors: [.theme.opacity(0.45), .clear],
                  center: .center,
                  startRadius: 1,
                  endRadius: 100
                )
              )
              .frame(width: 200, height: 100)
              .blur(radius: 30)
              .offset(y: 20)
          }
        )
        .cornerRadius(24)
        .shadow(color: Color.theme.opacity(0.3), radius: 15, x: 0, y: 5)
        .padding(.bottom, 16)

        Spacer()
      }
      .padding()
      VStack {
        HStack {
          Spacer()
          Circle()
            .fill(Color.theme.opacity(0.48))
            .frame(width: 100, height: 200)
            .blur(radius: 40)
            .padding(.leading)
          Spacer()
        }
        Spacer()
      }
      .ignoresSafeArea()
    }
    .background(Color(hex: "#f4f4f4"))
    .onAppear {
      let auth = router.checkAuth(tab: router.currentTab)
      if !auth {
        DispatchQueue.main.async {
          router.navigate(to: .login)
        }
      } else {
        Task {
          try await userService.refreshUserInfo()
        }
      }

    }
  }
}

#Preview {
  UserView()
    .environmentObject(Router())
    .environmentObject(UserService())
}
