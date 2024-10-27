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
    
    
    var user: UserInfo {
        return userService.user
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 16) {
                    Group {
                        SFSymbol.scan
                        Spacer()
                        SFSymbol.bell
                        SFSymbol.set
                            .onTapGesture {
                                router.navigate(to: .setting)
                            }
                    }
                    .font(.system(size: 20))
                }
                HStack (alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                        HStack {
                            Text("社区创始人")
                                .font(.system(size: 12))
                                .colorTag(.theme)
                        }
                        HStack(spacing: 32){
                            VStack(alignment: .leading){
                                Text(user.follow.description)
                                    .font(.system(size: 16))
                                Text("关注")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            VStack(alignment: .leading){
                                Text(user.fans.description)
                                    .font(.system(size: 16))
                                Text("粉丝")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    Spacer()
                    ImgLoader(user.avator ?? "user")
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
                   
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 32)
                HStack{
                    VStack(alignment: .leading,spacing: 4){
                        HStack{
                            Text(user.coin.description)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                            Text("积分")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Text("积分可用作奖励兑换")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.theme.opacity(0.88))
                .overlay{
                    VStack{
                        HStack{
                            Spacer()
                            SFSymbol.coin
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
                .cornerRadius(12)
                .padding(.bottom, 16)
                
                VStack {
                    HStack {
                        Text("我的发布")
                        Spacer()
                        SFSymbol.rightArrow
                    }
                    .padding(.bottom, 24)
                    HStack {
                        Text("我的参与")
                        Spacer()
                        SFSymbol.rightArrow
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(16)
                Spacer()
            }
            .padding()
            .background(Color(hex: "#f4f4f4"))
            VStack{
                HStack{
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
        .onAppear {
            let auth = router.checkAuth(tab: router.currentTab)
            if !auth {
                DispatchQueue.main.async {
                    router.navigate(to: .login)
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    UserView()
}
