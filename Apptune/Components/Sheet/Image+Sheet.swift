//
//  Image+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/24.
//

import SwiftUI

struct ToolbarButton: View {
  let icon: String
  let label: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: icon)
          .font(.system(size: 18))
          .frame(height: 22)
        Text(label)
          .font(.system(size: 11, weight: .medium))
      }
      .foregroundColor(.white)
      .frame(width: 48)
    }
  }
}

struct ImageSheet: View {
  @EnvironmentObject var sheet: SheetManager
  @State var selectedImage: UIImage?
  @State private var showImageEditor = false
  @State private var showImagePicker = true
  var onSelect: ((_ image: UIImage) -> Void)?
  var onCancel: (() -> Void)?

  var body: some View {
    if showImagePicker {
      ImagePicker(
        image: $selectedImage,
        onDismiss: {
          showImagePicker = false
          if selectedImage == nil {
            onCancel?()
            sheet.close()
          }
        }
      )
    } else if showImageEditor, let image = selectedImage {
      ImageClipComponent(
        selectedImage: image,
        onSelect: { image in
          selectedImage = image
          showImageEditor = false
        },
        onCancel: {
          showImageEditor = false
        })
    } else {
      if let image = selectedImage {
        VStack(spacing: 0) {
          // 图片预览区域
          ZStack {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .padding(.vertical, 100)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          // 底部工具栏
          VStack(spacing: 0) {
            Divider()
              .background(Color.white.opacity(0.15))

            HStack {
              // 左侧编辑按钮
              ToolbarButton(
                icon: "wand.and.stars",
                label: "编辑",
                action: { showImageEditor = true }
              )

              Spacer()

              // 右侧按��组
              HStack(spacing: 20) {
                ToolbarButton(
                  icon: "arrow.counterclockwise",
                  label: "重选",
                  action: {
                    showImagePicker = true
                  }
                )

                ToolbarButton(
                  icon: "xmark",
                  label: "取消",
                  action: {
                    selectedImage = nil
                    onCancel?()
                    sheet.close()
                  }
                )

                ToolbarButton(
                  icon: "checkmark",
                  label: "完成",
                  action: {
                    if let image = selectedImage {
                      onSelect?(image)
                      sheet.close()
                    }
                  }
                )
              }
            }
            .frame(height: 64)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
          }
          .padding()
        }
        .background(.black)
        .ignoresSafeArea()
      } else {
        EmptyView().onAppear {
          onCancel?()
          sheet.close()
        }
      }
    }
  }
}

#Preview {
  Text("sss")
    .sheet(
      isPresented: .constant(true),
      content: {
        ImageSheet()
      })
}
