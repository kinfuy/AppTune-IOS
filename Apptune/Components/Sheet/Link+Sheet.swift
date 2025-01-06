//
//  Link+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/6.
//

import SwiftUI

struct Link_Sheet: View {
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var notice: NoticeManager
  @State private var urlInput: String = ""
  @State private var isLoading: Bool = false
  @State private var previewData: PostLink?

  var onConfirm: ((_ link: PostLink) -> Void)?
  var onCancel: (() -> Void)?

  var body: some View {
    VStack(spacing: 24) {
      // 标题
      HStack {
        Text("添加链接")
          .font(.headline)
          .foregroundColor(.primary)
        Spacer()
        Button(action: {
          sheet.close()
        }) {
          Image(systemName: "xmark")
            .foregroundColor(.gray)
            .font(.system(size: 18))
        }
      }
      .padding(.bottom, 8)

      // URL 输入区域
      VStack(alignment: .leading, spacing: 8) {
        Text("链接地址")
          .font(.subheadline)
          .foregroundColor(.secondary)

        HStack(spacing: 12) {
          Image(systemName: "link")
            .foregroundColor(.gray)
          TextField("请输入或粘贴链接地址", text: $urlInput)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

          if !urlInput.isEmpty {
            Button(action: {
              urlInput = ""
            }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
            }
          }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
      }

      // 预览区域
      VStack(alignment: .leading, spacing: 12) {
        Text("预览")
          .font(.subheadline)
          .foregroundColor(.secondary)

        if isLoading {
          LoadingComponent()
            .frame(height: 80)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/)
        } else if let preview = previewData {
          LinkPreview(link: preview)
            .frame(maxWidth: .infinity)
        } else {
          Text("输入链接后查看预览")
            .foregroundColor(.gray)
            .frame(height: 80)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
      }

      Spacer()

      // 确认按钮
      Button(action: {
        if let link = previewData {
          onConfirm?(link)
          sheet.close()
        } else {
          notice.open(open: .toast("请输入链接"))
        }
      }) {
        Text("确认添加")
          .buttonStyle(.black)
          .frame(height: 44)
      }
      .disabled(previewData == nil)
    }
    .padding()
    .onChange(of: urlInput) { newValue in
      Task {
        await fetchPreview(for: newValue)
      }
    }
  }

  @MainActor
  private func fetchPreview(for url: String) async {
    // 如果 URL 为空，重置预览数据并返回
    guard !url.isEmpty else {
      previewData = nil
      return
    }

    // 验证 URL 格式是否合法
    guard let validURL = URL(string: url),
      validURL.scheme?.lowercased() == "http" || validURL.scheme?.lowercased() == "https"
    else {
      previewData = nil
      return
    }

    // 添加防抖动，等待用户停止输入
    try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms

    // 确保当前 URL 仍然是用户最后输入的值
    guard url == urlInput else {
      return
    }

    isLoading = true

    do {
      let preview = try await API.linkAnalysis(url)
      previewData = preview
    } catch {
      notice.open(open: .toast("链接解析失败"))
    }

    isLoading = false
  }
}

#Preview {
  Text("")
    .sheet(isPresented: .constant(true)) {
      Link_Sheet(onConfirm: { _ in })
        .environmentObject(SheetManager())
    }
}
