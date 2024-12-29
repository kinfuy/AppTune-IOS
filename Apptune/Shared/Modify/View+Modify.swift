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

// 添加必填标记的 ViewModifier
struct RequiredFieldModifier: ViewModifier {
  func body(content: Content) -> some View {
    HStack(spacing: 4) {
      content

      Text("*")
        .foregroundColor(.red)
        .font(.system(size: 14, weight: .bold))
    }
  }
}

// 添加导航栏样式的 ViewModifier
struct CustomNavigationBarModifier: ViewModifier {
  let title: String
  let router: Router
  var leadingItem: (() -> AnyView)? = nil
  var trailingItem: (() -> AnyView)? = nil

  func body(content: Content) -> some View {
    content
      .background(Color(hex: "#f4f4f4"))
      .navigationBarBackButtonHidden()
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(
        leading: leadingItem?() ?? defaultBackButton,
        trailing: trailingItem?()
      )
  }

  @MainActor
  private var defaultBackButton: AnyView {
    AnyView(
      Button(
        action: {
          router.back()
        },
        label: {
          HStack {
            SFSymbol.back
          }
          .foregroundStyle(Color(hex: "#333333"))
        }
      )
    )
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

  /// 添加必填标记（小红心）
  func required() -> some View {
    modifier(RequiredFieldModifier())
  }

  /// 添加自定义导航栏样式
  func customNavigationBar(
    title: String,
    router: Router,
    leadingItem: (() -> AnyView)? = nil,
    trailingItem: (() -> AnyView)? = nil
  ) -> some View {
    modifier(
      CustomNavigationBarModifier(
        title: title,
        router: router,
        leadingItem: leadingItem,
        trailingItem: trailingItem
      )
    )
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

// 更新预览示例，添加必填字段的演示
struct RequiredFieldExample: View {
  var body: some View {
    VStack(spacing: 20) {
      // 原有的 WatermarkExample 内容...

      // 添加必填字段示例
      TextField("用户名", text: .constant(""))
        .textFieldStyle(.roundedBorder)
        .required()
        .frame(width: 200)

      Text("手机号码")
        .required()
    }
    .padding()
  }
}

#Preview {
  VStack(spacing: 30) {
    WatermarkExample()
      .padding()
      .background(Color.gray.opacity(0.1))

    RequiredFieldExample()
  }
}
