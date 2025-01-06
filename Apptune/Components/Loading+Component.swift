//
//  Loading+Component.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/6.
//

import SwiftUI

struct LoadingComponent: View {
  // 创建一个动画状态变量
  @State private var isRotating = false

  // 可选参数，允许自定义颜色和大小
  var color: Color = .black
  var lineWidth: CGFloat = 3
  var size: CGFloat = 24

  var body: some View {
    Circle()
      .trim(from: 0, to: 0.7)
      .stroke(color, lineWidth: lineWidth)
      .frame(width: size, height: size)
      .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
      .animation(
        .linear(duration: 1)
          .repeatForever(autoreverses: false),
        value: isRotating
      )
      .onAppear {
        isRotating = true
      }
  }
}

// 预览
#Preview {
  // 在预览中展示不同大小的使用场景
  VStack(spacing: 20) {
    LoadingComponent()

    LoadingComponent(color: .blue)

    LoadingComponent(color: .red, lineWidth: 4)
  }
  .padding()
}
