//
//  Version+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/19.
//

import SwiftUI

struct Version_Modal: View {
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @Default(\.skinVersion) var skinVersion

  var body: some View {
    VStack {
      VStack(spacing: 8) {
        Text("AppTune 新版本")
          .fontWeight( /*@START_MENU_TOKEN@*/.bold /*@END_MENU_TOKEN@*/)
          .font(.system(size: 20))
        Spacer()
        HStack {

          Text("V\(appState.currentVersion)")
            .font(.system(size: 14))
          SFSymbol.rightShare
            .color(Color(hex: "#cccccc"))
          Text("V\(appState.latestVersion)")
            .font(.system(size: 18))
            .color(.theme)
            .fontWeight(.bold)
        }
        Text("升级 App 获得最新体验")
          .font(.system(size: 14))
          .color(.gray)
        // 更新操作
        Spacer()
        Button(action: {
          if let url = URL(string: "itms-apps://itunes.apple.com/app/id6661024172") {
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
          }
        }) {
          Text("立即更新")
            .font(.system(size: 16))
            .primaryButton()
            .padding(.horizontal, 30)

        }

        HStack {
          Text("跳过次版本")
            .font(.system(size: 14))
            .color(Color(hex: "#999999"))
            .onTapGesture {
              Tap.shared.play(.light)
              skinVersion = appState.latestVersion
              notice.close(id: VERSION_NOTICE_ID)
            }
        }
        .padding(.top, 8)
      }
      .padding(24)
      .frame(width: UIScreen.main.bounds.width * 0.78, height: 230)
      .background(.white)
      .cornerRadius(12)
    }
  }
}

#Preview {
  Version_Modal()
    .environmentObject(AppState())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
}
