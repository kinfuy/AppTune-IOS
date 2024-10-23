//
//  Agreement_Model.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/19.
//

import SwiftUI

struct Agreement_Model: View {
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var router: Router
  @Default(\.isAgreeMent) var isAgree: Bool
  var body: some View {
    VStack {
      Spacer()
      VStack(spacing: 8) {
        Text("请阅读并同意以下条款")
          .font(.system(size: 22))
          .fontWeight(.bold)
          .padding(.bottom, 12)
        HStack {
          Text("《用户协议》")
            .foregroundColor(Color(hex: "#555555"))
          Text("《隐私协议》")
            .foregroundColor(Color(hex: "#555555"))
        }
        VStack {
          Text("《儿童/青少年个人信息保护规则》")
            .foregroundColor(Color(hex: "#555555"))
        }
        .padding(.bottom, 12)
        Text("同意并继续")
          .fontWeight(.bold)
          .primaryButton()
          .frame(height: 48)
          .onTapGesture {
            isAgree = true
            router.closeNotice(id: AGGREEMENT_NOTICE_ID)
          }
      }
      .padding()
      .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: 240)
      .padding(.bottom, 32)
      .background(.white)
      .clipShape(RoundedCorners(topLeft: 24, topRight: 24))

    }
    .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: .infinity)
    .ignoresSafeArea()
  }
}

#Preview {
  ZStack {
    VStack {}
      .frame(
        maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: .infinity
      )
      .ignoresSafeArea(.all)
      .background(.black.opacity(0.48))
    Agreement_Model()
      .environmentObject(AppState())
  }

}
