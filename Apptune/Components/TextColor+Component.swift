//
//  PayWall.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/9/21.
//

import SwiftUI

struct TextColor: View {
    var text = ""
    var size:CGFloat = 24
    var startColor = Color(hex: "#b1f4cf")
    var endColor = Color(hex: "#9890e3")
    var annotation = true
    @State private var isAnimating = false
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: isAnimating ? [startColor, endColor] : [endColor, startColor]),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        .frame(height: size)
        .mask {
            Text(text)
                .font(.system(size: size))
                .fontWeight(.heavy)
        }
        .conditionalModifier(annotation, modifier: { view in
            view
                .animation(.easeInOut(duration: 3), value: isAnimating)
                .onReceive(timer) { _ in
                    isAnimating.toggle()
                }
        })
       
        .padding(0)
    }
}

#Preview {
    TextColor()
}
