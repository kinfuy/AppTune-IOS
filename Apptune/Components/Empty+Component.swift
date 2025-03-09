//
//  Empty.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/9/12.
//

import SwiftUI

struct EmptyView: View {
  // 基础属性
  var text: String = "暂无数据"
  var subText: String = ""
  var image: String?
  var size: CGFloat = 160

  // 自定义样式
  var imageOpacity: Double = 0.8
  var spacing: CGFloat = 16
  var alignment: VerticalAlignment = .center
  var primaryColor: Color = .blue

  // 动画状态
  @State private var isAnimating = false
  @State private var orbitAngle = 0.0
  @State private var planetScale: CGFloat = 1
  @State private var starOpacity: Double = 0.3

  // 动画时间
  private let orbitDuration: Double = 8

  // 自定义动画形状
  private var defaultAnimation: some View {
    ZStack {
      // 星星背景
      ForEach(0..<12) { index in
        Circle()
          .fill(primaryColor)
          .frame(width: 4, height: 4)
          .offset(
            x: CGFloat.random(in: -size / 2...size / 2),
            y: CGFloat.random(in: -size / 2...size / 2)
          )
          .opacity(starOpacity)
          .animation(
            Animation.easeInOut(duration: 1.5)
              .repeatForever()
              .delay(Double(index) * 0.1),
            value: starOpacity
          )
      }

      // 轨道
      Circle()
        .stroke(
          primaryColor.opacity(0.2),
          style: StrokeStyle(
            lineWidth: 1,
            dash: [2, 4]
          )
        )
        .frame(width: size * 0.8, height: size * 0.8)

      // 行星轨道动画组
      ForEach(0..<3) { index in
        // 小行星
        ZStack {
          Circle()
            .fill(primaryColor.opacity(0.8))
            .frame(width: 8, height: 8)
            .shadow(color: primaryColor.opacity(0.3), radius: 2)

          // 行星光环
          Circle()
            .stroke(primaryColor.opacity(0.3), lineWidth: 1)
            .frame(width: 12, height: 12)
        }
        .offset(y: -size * 0.3)
        .rotationEffect(.degrees(orbitAngle + Double(index) * 120))
        .animation(
          Animation.linear(duration: orbitDuration)
            .repeatForever(autoreverses: false),
          value: orbitAngle
        )
      }

      // 中心星球
      ZStack {
        // 发光效果
        Circle()
          .fill(
            RadialGradient(
              gradient: Gradient(colors: [
                primaryColor.opacity(0.5),
                primaryColor.opacity(0),
              ]),
              center: .center,
              startRadius: 0,
              endRadius: size * 0.3
            )
          )
          .frame(width: size * 0.5, height: size * 0.5)
          .scaleEffect(planetScale)

        // 主星球
        Circle()
          .fill(primaryColor)
          .frame(width: size * 0.25, height: size * 0.25)
          .shadow(color: primaryColor.opacity(0.5), radius: 10)
          .scaleEffect(planetScale)

        // 星球环
        Circle()
          .trim(from: 0.3, to: 0.7)
          .stroke(primaryColor.opacity(0.6), lineWidth: 2)
          .frame(width: size * 0.35, height: size * 0.35)
          .rotationEffect(.degrees(-45))
          .scaleEffect(planetScale)
      }
      .animation(
        Animation.easeInOut(duration: 2)
          .repeatForever(autoreverses: true),
        value: planetScale
      )
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: spacing) {
      if let imageName = image, !imageName.isEmpty {
        Image(imageName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: size, height: size)
          .opacity(imageOpacity)
      } else {
        defaultAnimation
          .frame(width: size, height: size)
      }

      VStack(spacing: 12) {
        if !text.isEmpty {
          Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.secondary)
        }

        if !subText.isEmpty {
          Text(subText)
            .font(.system(size: 14))
            .foregroundColor(.secondary.opacity(0.8))
            .multilineTextAlignment(.center)
        }
      }
    }
    .frame(
      maxWidth: .infinity, maxHeight: .infinity, alignment: alignment == .center ? .center : .top
    )
    .padding()
    .onAppear {
      withAnimation {
        isAnimating = true
        orbitAngle = 360
        planetScale = 1.1
        starOpacity = 1
      }
    }
    .onDisappear {
      isAnimating = false
      orbitAngle = 0
      planetScale = 1
      starOpacity = 0.3
    }
  }
}

// 预览
#Preview("主题色") {
  HStack {
    EmptyView(
      text: "暂无数据",
      subText: "开始探索宇宙吧",
      primaryColor: .blue
    )
    EmptyView(
      text: "暂无数据",
      subText: "开始探索宇宙吧",
      primaryColor: .purple
    )
  }
}

#Preview("场景预览") {
  VStack(spacing: 20) {
    EmptyView(
      text: "暂无收藏",
      subText: "去发现更多精彩内容吧",
      primaryColor: .orange
    )

    EmptyView(
      text: "暂无消息",
      subText: "静待好消息的到来",
      primaryColor: .green
    )
  }
}
