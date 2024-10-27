//
//  Confirm+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//

import SwiftUI

struct Confirm_Modal: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router
    var id:String
    var titile: String
    var desc: String = ""
    var onSubmit: (() -> Void)
    var onCancel: (() -> Void)
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text(titile)
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .padding(.bottom, 12)
                if desc != "" {
                    Text(desc)
                        .font(.system(size: 16))
                        .color(.gray)
                        .padding(.bottom, 12)
                }
                Spacer()
                HStack {
                    Text("取消")
                        .fontWeight(.bold)
                        .buttonStyle(Color(hex: "#eeeeee"), .black)
                        .frame(height: 38)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Tap.shared.play(.light)
                            DispatchQueue.main.async {
                                router.closeNotice(id:id)
                                onCancel()
                            }
                        }

                    Text("确认")
                        .fontWeight(.bold)
                        .buttonStyle(.black)
                        .frame(height: 38)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Tap.shared.play(.light)
                            DispatchQueue.main.async {
                                router.closeNotice(id:id)
                                onSubmit()
                            }
                        }
                }
            }
            .padding()
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: 180)
            .padding(.bottom, 32)
            .background(.white)
            .clipShape(RoundedCorners(topLeft: 24, topRight: 24))
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .ignoresSafeArea()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
