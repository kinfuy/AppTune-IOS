//
//  SubmitActiveReviewView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import PhotosUI
import SwiftUI

enum ReviewMode {
  case view  // 查看模式
  case edit  // 编辑模式
  case review  // 审核模式
}

struct SubmitActiveReviewView: View {
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var sheet: SheetManager
  var active: ActiveInfo
  @State var mode: ReviewMode

  @State private var content: String = ""
  @State private var images: [String] = []
  @State private var isSubmitting = false
  @State private var historyReviews: [ReviewRecord] = []
  @State private var isLoadingHistory = false
  @State private var hasSubmitted = true
  @State private var reviewStatus: ReviewStatus = .pending
  @State private var reviewReason: String = ""

  // 上传图片
  private func uploadImage(_ image: UIImage) async -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
    do {
      let url = try await API.uploadAvatar(imageData, loading: true)
      return url
    } catch {
      notice.openNotice(open: .toast("图片上传失败"))
      return nil
    }
  }

  private var canSubmit: Bool {
    switch mode {
    case .edit:
      return !content.isEmpty && !isSubmitting
    case .review:
      return !isSubmitting && (reviewStatus != .pending || !reviewReason.isEmpty)
    case .view:
      return false
    }
  }

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // 内容展示部分
          contentSection

          // 审核操作部分（仅在审核模式下显示）
          if mode == .review {
            reviewSection
          }

          // 历史记录部分
          if !historyReviews.isEmpty {
            historySection
          }
        }
        .padding(.horizontal)
        .padding(.top)
      }

      // 底部按钮
      bottomButton
    }
    .navigationTitle(navigationTitle)
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: {
          router.back()
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
            }
          }
          .foregroundStyle(Color(hex: "#333333"))
        })
    )
    .onAppear {
      Task {
        // 检查提交状态
        let status = await activeService.checkActiveStatus(id: active.id)
        hasSubmitted = status.hasSubmitted
        if mode != .review {
          mode = hasSubmitted ? .view : .edit
        }

        await loadHistoryReviews()
      }
    }
  }

  // 导航栏标题
  private var navigationTitle: String {
    switch mode {
    case .view: return "查看审核"
    case .edit: return "提交审核"
    case .review: return "审核"
    }
  }

  // 内容展示部分
  private var contentSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      if mode == .edit {
        editableContent
      } else {
        readOnlyContent
      }
    }
  }

  // 可编辑内容
  private var editableContent: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 图片上传部分
      imageUploadSection

      // 文本输入部分
      CustomTextField(
        text: $content,
        placeholder: "活动描述",
        isMultiline: true,
        maxLength: 500
      )
    }
  }

  // 只读内容
  private var readOnlyContent: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("审核内容")
        .font(.headline)

      VStack(alignment: .leading, spacing: 12) {
        Text(content)
          .font(.system(size: 15))

        if !images.isEmpty {
          imageGridView
        }
      }
      .padding()
      .background(Color.white)
      .cornerRadius(12)
      .shadow(color: .gray.opacity(0.05), radius: 8)
    }
  }

  // 审核操作部分
  private var reviewSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("审核操作")
        .font(.headline)

      // 审核状态选择
      Picker("审核状态", selection: $reviewStatus) {
        Text("通过").tag(ReviewStatus.approved)
        Text("拒绝").tag(ReviewStatus.rejected)
      }
      .pickerStyle(.segmented)

      // 审核意见输入
      CustomTextField(
        text: $reviewReason,
        placeholder: "请输入审核意见（必填）",
        isMultiline: true,
        maxLength: 200
      )
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  // 底部按钮
  private var bottomButton: some View {
    Group {
      if mode != .view {
        Button(action: {
          Task {
            if mode == .edit {
              await submitReview()
            } else {
              await submitAuditResult()
            }
          }
        }) {
          if isSubmitting {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text(mode == .edit ? "提交审核" : "提交")
          }
        }
        .buttonStyle(.black)
        .frame(height: 48)
        .padding()
        .disabled(!canSubmit)
      }
    }
  }

  // 提交审核结果
  private func submitAuditResult() async {
    isSubmitting = true
    // 这里需要实现提交审核结果的API调用
    // await activeService.submitAuditResult(
    //     activeId: active.id,
    //     status: reviewStatus,
    //     reason: reviewReason
    // )
    isSubmitting = false
    notice.openNotice(open: .toast("审核完成"))
    router.back()
  }

  func submitReview() async {
    isSubmitting = true

    await activeService.submitAudit(
      activeId: active.id,
      content: content,
      images: images
    )

    isSubmitting = false
    notice.openNotice(open: .toast("提交成功"))
    router.back()
  }

  func loadHistoryReviews() async {
    isLoadingHistory = true
    // 加载历史审核记录
    if let submission = await activeService.getReviewHistory(activeId: active.id) {
      content = submission.content
      images = submission.images ?? []
      historyReviews = submission.reviewHistory
    }
    isLoadingHistory = false
  }

  // 历史记录部分
  private var historySection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("审核记录")
        .font(.headline)
        .padding(.horizontal)

      ForEach(historyReviews, id: \.reviewerId) { record in
        ReviewRecordCard(record: record)
      }

      if isLoadingHistory {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
        .padding()
      }
    }
  }

  // 图片上传部分
  private var imageUploadSection: some View {
    VStack(alignment: .leading) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          // 上传按钮
          Button(action: {
            sheet.show(
              .imagePicker(onSelect: { image in
                Task {
                  if let url = await uploadImage(image) {
                    images.append(url)
                  }
                }
              }))
          }) {
            Rectangle()
              .fill(Color(hex: "#f4f4f4"))
              .frame(width: 100, height: 100)
              .cornerRadius(8)
              .overlay(
                VStack(spacing: 8) {
                  Image(systemName: "plus")
                    .font(.system(size: 32))
                }
                .foregroundColor(.gray)
              )
          }

          // 已上传图片
          if !images.isEmpty {
            ForEach(images, id: \.self) { image in
              ImgLoader(image)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
                .overlay(
                  Button(action: {
                    images.removeAll { $0 == image }
                  }) {
                    SFSymbol.close
                      .font(.system(size: 12))
                      .padding(4)
                      .background(.black.opacity(0.7))
                      .cornerRadius(4)
                      .foregroundColor(.white)
                  }
                  .padding(4),
                  alignment: .topTrailing
                )
            }
          }
        }
      }
    }
  }

  // 图片网格视图
  private var imageGridView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(images, id: \.self) { imageUrl in
          ImgLoader(imageUrl)
            .frame(width: 80, height: 80)
            .cornerRadius(8)
        }
      }
    }
  }
}

// 历史审核记录卡片
struct ReviewRecordCard: View {
  let record: ReviewRecord

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 审核状态和时间
      HStack {
        Text(record.status.description)
          .font(.system(size: 14))
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(record.status.color.opacity(0.1))
          .foregroundColor(record.status.color)
          .cornerRadius(4)

        Spacer()

        Text(record.reviewTime.formatted())
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }

      // 添加审核消息展示
      if let message = record.reason, !message.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text("审核意见")
            .font(.system(size: 14))
            .foregroundColor(.secondary)

          Text(message)
            .font(.system(size: 15))
            .foregroundColor(.primary)
            .padding(12)
            .background(Color(hex: "#f8f8f8"))
            .cornerRadius(8)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.05), radius: 8)
    .padding(.horizontal)
  }
}

// 审核记录模型
struct ReviewRecord: Codable {
  let reviewerId: String
  let reviewTime: Date
  let status: ReviewStatus
  let reason: String?
}

// 审核状态
enum ReviewStatus: Int, Codable {
  case pending = 1
  case approved = 2
  case rejected = 3

  var description: String {
    switch self {
    case .pending: return "待审核"
    case .approved: return "已通过"
    case .rejected: return "已拒绝"
    }
  }

  var color: Color {
    switch self {
    case .pending: return .orange
    case .approved: return .green
    case .rejected: return .red
    }
  }
}

#Preview {
  NavigationStack {
    SubmitActiveReviewView(
      active: ActiveInfo(
        id: "1",
        title: "测试活动",
        description: "这是个测试活动",
        cover: "https://picsum.photos/200",
        startAt: Date(),
        endAt: nil,
        limit: nil,
        rewardType: .points,
        joinCount: 0,
        likeCount: 0,
        status: 1,
        createTime: Date(),
        productId: "1",
        productName: "测试产品",
        productLogo: "https://picsum.photos/100",
        images: [],
        tags: [],
        link: nil,
        reward: nil,
        rewardPoints: 100,
        rewardPromoCodes: nil,
        userId: "1",
        isTop: false,
        recommendTag: nil,
        recommendDesc: nil,
        pubMode: .pro
      ),
      mode: .review
    )
    .environmentObject(ActiveService())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
  }
}
