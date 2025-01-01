//
//  Join+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/1.
//

import SwiftUI

struct Join_Modal: View {
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var router: Router

  var body: some View {
    VStack {
      VStack(spacing: 12) {
        // 顶部图标
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 40))
          .foregroundColor(.green)
          .padding(.bottom, 8)

        // 标题
        Text("恭喜报名成功")
          .fontWeight(.bold)
          .font(.system(size: 20))

        // 描述文本
        Text("提交审核资料完成任务，即可获得奖励")
          .font(.system(size: 14))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)

        Spacer()

        // 确认按钮
        Button(action: {
          notice.closeNotice(id: JOIN_SUCCESS_NOTICE_ID)
        }) {
          Text("我知道了")
            .font(.system(size: 16))
            .primaryButton()
            .padding(.horizontal, 30)
        }
      }
      .padding(24)
      .frame(width: UIScreen.main.bounds.width * 0.78, height: 240)
      .background(.white)
      .cornerRadius(12)
    }
  }
}

#Preview {
  Join_Modal()
    .environmentObject(NoticeManager())
    .environmentObject(Router())
}
