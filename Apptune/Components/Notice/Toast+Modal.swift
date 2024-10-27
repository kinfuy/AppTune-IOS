//
//  Toast+Modal.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/20.
//

import SwiftUI

struct Toast_Modal: View {
    @EnvironmentObject var router: Router
    var id: String
    var messgae: String = ""
    var time: CGFloat = 1.5
    var loading: Bool = true

    var body: some View {
        VStack {
            if loading {
                ProgressView()
                    .scaleEffect(1.5, anchor: .center)
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .white)
                    )
                    .padding(.bottom)
            }
                
            Text(messgae)
                .color(.white)
                .font(.system(size: 14))
        }
        .if(loading, transform: { view in
            view
                .frame(width: 100, height: 100)

        })
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(loading ? .black.opacity(0.88) : .black)
        .cornerRadius(8)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.78)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
