//
//  FirshProduct+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/1.
//

import SwiftUI

struct FirshProduct_Modal: View {
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var router: Router
  @Default(\.lastProductNoticeDismissDate) var lastProductNoticeDismissDate

  var body: some View {
    VStack {
      VStack(spacing: 12) {
        // 顶部图标
        Image(systemName: "sparkles.square.filled.on.square")
          .font(.system(size: 40))
          .foregroundColor(.theme)
          .padding(.bottom, 8)

        // 标题
        Text("发布一个产品")
          .fontWeight(.bold)
          .font(.system(size: 20))

        // 描述文本
        Text("即可成为开发者，解锁更多有趣功能")
          .font(.system(size: 14))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)

        Spacer()

        // 创建按钮
        Button(action: {
          // TODO: 跳转到创建产品页面
          notice.close(id: FIRST_PRODUCT_NOTICE_ID)
          router.navigate(to: .publishProduct)
        }) {
          Text("立即创建")
            .font(.system(size: 16))
            .primaryButton()
            .padding(.horizontal, 30)
        }

        // 跳过按钮
        Text("7 日不再提示")
          .font(.system(size: 14))
          .foregroundColor(Color(hex: "#999999"))
          .padding(.top, 8)
          .onTapGesture {
            Tap.shared.play(.light)
            // 记录关闭时间
            lastProductNoticeDismissDate = Date()
            notice.close(id: FIRST_PRODUCT_NOTICE_ID)
          }
      }
      .padding(24)
      .frame(width: UIScreen.main.bounds.width * 0.78, height: 280)
      .background(.white)
      .cornerRadius(12)
    }
  }
}

#Preview {
  FirshProduct_Modal()
    .environmentObject(NoticeManager())
}
