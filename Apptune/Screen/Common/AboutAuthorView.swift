//
//  VersionView.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/10/2.
//

import SwiftUI

enum SocialLinks: String {
  case redbook = "https://www.xiaohongshu.com/user/profile/647d275f0000000011001181"
  case jike = "https://okjk.co/ZCQ2pD"
  case suka = "https://apps.apple.com/us/app/suka-digital-card/id6661024172?uo=4"
  case devtester =
    "https://chromewebstore.google.com/detail/devtester/lgdplgdlaacpegfninnaekfcpajmafga?hl=en&authuser=0"
}

struct AboutAuthorView: View {
  @EnvironmentObject var router: Router

  var body: some View {
    VStack {
      HStack {
        ImgLoader("user")
          .frame(width: 58, height: 58)
          .clipShape(.rect(cornerRadius: 8))
        VStack(alignment: .leading) {
          Text("阿乐去买菜")
            .foregroundColor(.black)
            .fontWeight(.heavy)
          HStack {
            Text("点点星光")
              .colorTag(.gray)
              .font(.system(size: 14))

          }
        }
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .padding()
      .cornerRadius(12)
      VStack {
        HStack {
          Text("社交媒体")
            .foregroundColor(.gray)
            .font(.system(size: 18))
          Spacer()
        }

        VStack(spacing: 24) {
          Link(
            destination: URL(string: SocialLinks.redbook.rawValue)!,
            label: {
              HStack {
                ImgLoader("redbook")
                  .frame(width: 32, height: 32)
                Text("小红书")
                Spacer()
                SFSymbol.rightArrow
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
              }
            })
          Link(
            destination: URL(string: SocialLinks.jike.rawValue)!,
            label: {
              HStack {
                ImgLoader("jike")
                  .frame(width: 32, height: 32)
                Text("即刻")
                Spacer()
                SFSymbol.rightArrow
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
              }
            })
        }
        .foregroundColor(.black)
        .frame(width: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)

        HStack {
          Text("更多作品")
            .foregroundColor(.gray)
            .font(.system(size: 18))
          Spacer()
        }
        .padding(.top, 8)
        VStack(spacing: 24) {
          Link(
            destination: URL(string: SocialLinks.suka.rawValue)!,
            label: {
              HStack {
                ImgLoader("suka")
                  .frame(width: 42, height: 42)
                  .clipShape(.rect(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                  HStack {
                    Text("Suka数字卡片")
                    Text("ios")
                      .font(.system(size: 12))
                      .colorTag(.gray)
                  }
                  Text("遇见数字，发现有趣")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                }
                Spacer()
                SFSymbol.rightArrow
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
              }
            })
          Link(
            destination: URL(string: SocialLinks.devtester.rawValue)!,
            label: {
              HStack {
                VStack {
                  ImgLoader("devtester")
                    .frame(width: 32, height: 32)

                }
                .frame(width: 42, height: 42)
                .clipShape(.rect(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                  HStack {
                    Text("DevTester")
                    Text("chrome")
                      .font(.system(size: 12))
                      .colorTag(.gray)
                  }
                  Text("专注于开发测试的简单实用浏览器小工具集合")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                }
                Spacer()
                SFSymbol.rightArrow
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
              }
            })
        }
        .foregroundColor(.black)
        .frame(width: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)

      }
      .padding(.top, 16)
      Spacer()
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarItems(
      leading: Button(
        action: {
          router.back()
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
              Text("返回")
            }
          }
          .onTapGesture {
            router.back()
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
