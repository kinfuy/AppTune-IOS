//
//  ImageSave+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/14.
//

import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ImageShareSheet: View {
  @EnvironmentObject var notice: NoticeManager

  var shareImage: UIImage
  var title: String
  var onSave: (() -> Void)?

  // 保存图片到相册的方法
  private func saveImageToAlbum() {
    Task {
      do {
        // 1. 先请求权限
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

        // 2. 根据权限状态处理
        switch status {
        case .authorized, .limited:
          // 有权限，执行保存操作
          try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: shareImage)
            request.creationDate = Date()
          }
          notice.openNotice(open: .toast("图片已经保存的相册"))
          if let save = onSave {
            save()
          }
        case .denied, .restricted:
          notice.openNotice(
            open: .confirm(
              Confirm(
                title: "请允许保存图片权限",
                onSuccess: {
                  if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                  }
                })))

        case .notDetermined:
          // 理论上不会到这里，因为前面已经请求过权限了
          break

        @unknown default:
          break
        }
      } catch {
        notice.openNotice(open: .toast("保存图片失败: \(error.localizedDescription)"))
      }
    }
  }

  var body: some View {
    VStack {
      HStack {
        Spacer()
        // 分享按钮
        ShareLink(
          item: Image(uiImage: shareImage),
          preview: SharePreview(
            title,
            image: Image(uiImage: shareImage)
          )
        ) {
          HStack {
            Image(systemName: "square.and.arrow.up")
            Text("分享")
          }
        }
      }
      Spacer()
      // 预览图片卡片
      Image(uiImage: shareImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)

      Spacer()

      // 添加操作按钮组
      HStack(spacing: 20) {
        // 保存到相册按钮
        Button(action: saveImageToAlbum) {
          HStack {
            Image(systemName: "square.and.arrow.down")
            Text("保存到相册")
          }
          .buttonStyle(.black)
          .frame(height: 32)
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#f4f4f4"))
  }
}
