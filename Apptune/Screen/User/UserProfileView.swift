//
//  UserProfileView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/27.
//

import SwiftUI

struct UserProfileView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var userService: UserService

  var body: some View {
    VStack {
      HStack {
        ImgLoader(userService.user.avatar)
          .frame(width: 78, height: 78)
          .clipShape(.circle)
      }
      .padding()
      HStack {
        Text(userService.user.name)
          .foregroundColor(.black)
          .fontWeight(.heavy)
        Text(userService.user.email)
          .colorTag(.gray)
          .font(.system(size: 14))
      }
      Spacer()
    }
    .frame(minWidth: .infinity)
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("编辑资料")
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
