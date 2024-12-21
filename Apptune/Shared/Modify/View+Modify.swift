//
//  View+Modify.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/14.
//

import SwiftUI

// 创建水印的 ViewModifier
struct CreatedByWatermarkModifier: ViewModifier {
  let logo: String

  func body(content: Content) -> some View {
    VStack(alignment: .trailing, spacing: 8) {
      content

      // 水印部分使用半透明背景提升视觉效果
      HStack(spacing: 6) {
        Text("Created By")
          .font(.system(size: 12, weight: .regular))
          .foregroundColor(.gray.opacity(0.8))

        ImgLoader(logo)
          .frame(width: 16, height: 16)
          .cornerRadius(all: 4)

        Text("Apptune")
          .font(.system(size: 13, weight: .medium))
          .foregroundColor(.gray.opacity(0.9))
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.white.opacity(0.8))
          .shadow(color: .black.opacity(0.05), radius: 2)
      )
      .padding(.bottom, 4)
      .padding(.trailing, 4)
    }
  }
}

// View 的扩展，添加水印方法
extension View {
  func createdBy(
    _ logo: String?
  ) -> some View {
    modifier(
      CreatedByWatermarkModifier(
        logo: logo ?? "logo"
      ))
  }
}

// 预览示例
struct WatermarkExample: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "star.fill")
        .font(.system(size: 50))
        .foregroundColor(.yellow)
        .shadow(color: .orange.opacity(0.3), radius: 2)

      Text("精彩内容")
        .font(.title2.bold())
        .foregroundColor(.primary)
    }
    .frame(width: 220, height: 160)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(
          color: .black.opacity(0.1),
          radius: 8, x: 0, y: 2)
    )
    .createdBy(nil)
  }
}

#Preview {
  WatermarkExample()
    .padding()
    .background(Color.gray.opacity(0.1))
}
