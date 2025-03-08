//
//  Loading+Component.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/6.
//

import SwiftUI

struct LoadingComponent: View {
  @State private var isRotating = false

  // 保留原有的color参数
  var color: Color?
  // 添加可选的渐变色参数
  var gradient: LinearGradient = LinearGradient(
    colors: [Color.blue, Color.purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  var lineWidth: CGFloat = 3
  var size: CGFloat = 24

  var body: some View {
    Circle()
      .trim(from: 0, to: 0.7)
      .stroke(color != nil ? AnyShapeStyle(color!) : AnyShapeStyle(gradient), lineWidth: lineWidth)
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
  VStack(spacing: 20) {
    // 使用默认渐变色
    LoadingComponent()

    // 使用传统的单色方式
    LoadingComponent(color: .blue)

    // 自定义渐变色
    LoadingComponent(
      gradient: LinearGradient(
        colors: [.red, .orange],
        startPoint: .leading,
        endPoint: .trailing
      )
    )

    // 使用单色并自定义线宽
    LoadingComponent(color: .red, lineWidth: 4)
  }
  .padding()
}
