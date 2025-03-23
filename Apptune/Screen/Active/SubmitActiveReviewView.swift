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
  var userId: String?

  @State private var content: String = ""
  @State private var images: [String] = []
  @State private var isSubmitting = false
  @State private var historyReviews: [ReviewRecord] = []
  @State private var isLoadingHistory = false
  @State private var hasSubmitted = true
  @State private var reviewStatus: ReviewStatus = .pending
  @State private var reviewReason: String = ""

  @State private var isLoading = false
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false
  @State private var auditLoaing = false

  // 上传图片
  private func uploadImage(_ image: UIImage) async -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
    do {
      let url = try await API.uploadAvatar(imageData, loading: true)
      return url
    } catch {
      notice.open(open: .toast("图片上传失败"))
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

  @MainActor
  private func confirmReward(desc: String?, extra: SubmitExtraParams? = nil) async {
    notice.open(
      open: .confirm(
        title: "确定通过审核吗？",
        desc: desc ?? "",
        onSuccess: {
          Task {
            reviewStatus = .approved
            await submitAuditResult(extra: extra)
          }
        }))
  }

  // 检查奖励
  private func checkRewardValidity() async {
    if active.rewardType == .promoCode {
      // rewardPromoCodes 多个需要用户选择
      if active.rewardPromoCodes?.count ?? 0 > 1 {
        sheet.show(
          .preCodePicker(
            productId: active.productId,
            selectedGroups: [],
            onSelect: { groups in
              Task {
                let group = groups[0]
                let desc = "审核通过将奖励用户\(group)优惠码"
                await confirmReward(
                  desc: desc, extra: SubmitExtraParams(userId: userId, group: group))
              }
            },
            onCancel: nil,
            config: ProCodeSheetConfig(allowMultipleSelection: false, title: "绑定优惠码分组")))
      } else {
        await confirmReward(
          desc: "审核通过将奖励用户 \(active.rewardPromoCodes?.first ?? "") 优惠码",
          extra: SubmitExtraParams(userId: userId, group: active.rewardPromoCodes?.first ?? ""))
      }
    }

    if active.rewardType == .points {
      if let points = active.rewardPoints {
        await confirmReward(desc: "审核通过将奖励用户 \(points.description) 积分")
      } else {
        await confirmReward(desc: "审核通过将奖励用户")
      }
    }
    if active.rewardType == .selfManaged {
      await confirmReward(desc: "审核通过将奖励用户")
    }

  }

  var auditButtons: some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 12) {
        // 主按钮 - 通过
        Button(action: {
          Task {
            await checkRewardValidity()
          }
        }) {
          HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("通过审核")
          }
          .loadingButton(loading: isLoading)
          .buttonStyle(.black)
          .frame(height: 44)
        }

        // 辅助按钮 - 驳回
        Button(action: {
          notice.open(
            open: .confirm(
              title: "确定驳回审核吗？",
              onSuccess: {
                Task {
                  reviewStatus = .rejected
                  await submitAuditResult()
                }
              }))
        }) {
          HStack(spacing: 4) {
            Image(systemName: "xmark.circle.fill")
            Text("驳回")
          }
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.gray)
          .frame(width: 90, height: 44)
          .background(Color.gray.opacity(0.1))
          .cornerRadius(22)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
    }
  }

  var submitButton: some View {
    Button(action: {
      Task {
        await submitReview()
      }
    }) {
      Text("提交")
    }
    .buttonStyle(.black)
    .frame(height: 48)
    .padding()
    .disabled(!canSubmit)
  }

  var body: some View {
    VStack {
      if isLoading {
        LoadingComponent()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
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

        Spacer()

        // 底部按钮
        if mode == .review {
          auditButtons
        }
        if mode == .edit {
          submitButton
        }
      }
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
      isLoading = true
      Task {
        // 检查提交状态
        let status = await activeService.checkActiveStatus(id: active.id)
        hasSubmitted = status.hasSubmitted

        await loadHistoryReviews(userId: userId)

        isLoading = false
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

      // 审核意见输入
      CustomTextField(
        text: $reviewReason,
        placeholder: "请输入审核意见",
        isMultiline: true,
        verticalPadding: 0,
        maxLength: 200
      )
    }
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
  private func submitAuditResult(extra: SubmitExtraParams? = nil) async {
    if userId == nil {
      return
    }
    isSubmitting = true
    // 这里需要实现提交审核结果的API调用
    await activeService.submitAuditResult(
      activeId: active.id,
      userId: userId!,
      status: reviewStatus,
      reason: reviewReason,
      extra: extra,
      success: {
        isSubmitting = false
        notice.open(open: .toast("审核完成"))
        Task {
          await loadHistoryReviews(userId: userId)
        }
      }
    )
  }

  func submitReview() async {
    isSubmitting = true

    await activeService.submitAudit(
      activeId: active.id,
      content: content,
      images: images,
      success: {
        isSubmitting = false
        notice.open(open: .toast("提交成功"))
        router.back()
      }
    )
  }

  func loadHistoryReviews(userId: String?) async {
    isLoadingHistory = true
    // 加载历史审核记录
    if let submission = await activeService.getReviewHistory(activeId: active.id, userId: userId) {
      content = submission.content
      images = submission.images ?? []
      historyReviews = submission.reviewHistory
    }
    isLoadingHistory = false

    // 检查审核状态
    if let lastReview = historyReviews.first {
      switch lastReview.status {
      case .approved:
        mode = .view
      case .rejected:
        // 被拒绝时，如果不是审核模式，则设置为编辑模式
        if mode != .review {
          mode = .edit
        }
      case .pending:
        // 待审核状态
        if mode != .review {
          mode = .view
        }
      }
    } else {
      // 没有审核记录时
      mode = hasSubmitted ? .view : .edit
    }
  }

  // 历史记录部分
  private var historySection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("审核记录")
        .font(.headline)
        .padding(.horizontal)

      ForEach(historyReviews, id: \.reviewTime) { record in
        ReviewRecordCard(record: record)
      }

      if isLoadingHistory {
        HStack {
          Spacer()
          LoadingComponent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
          ImgLoader(imageUrl, contentMode: .fill, canPreview: true)
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
            .font(.system(size: 12))
            .foregroundColor(.primary)
            .lineLimit(5)
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

#Preview("查看模式") {
  NavigationStack {
    SubmitActiveReviewView(
      active: mockActive,
      mode: .view,
      userId: "1"
    )
    .environmentObject(ActiveService())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
    .environmentObject(SheetManager())
  }
}

#Preview("审核模式") {
  NavigationStack {
    SubmitActiveReviewView(
      active: mockActive,
      mode: .review,
      userId: "1"
    )
    .environmentObject(ActiveService())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
    .environmentObject(SheetManager())
  }
}

#Preview("编辑模式") {
  NavigationStack {
    SubmitActiveReviewView(
      active: mockActive,
      mode: .edit,
      userId: "1"
    )
    .environmentObject(ActiveService())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
    .environmentObject(SheetManager())
  }
}

// 添加模拟数据
private let mockActive = ActiveInfo(
  id: "1",
  title: "测试活动",
  description: "这是个测试活动描述",
  cover: "https://picsum.photos/200",
  startAt: Date(),
  endAt: Date().addingTimeInterval(86400),
  isAutoEnd: true,
  limit: 100,
  rewardType: .points,
  joinCount: 10,
  likeCount: 5,
  status: 1,
  createTime: Date(),
  productId: "1",
  productName: "测试产品",
  productLogo: "https://picsum.photos/100",
  images: ["https://picsum.photos/200", "https://picsum.photos/201"],
  tags: [],
  link: "https://example.com",
  reward: nil,
  auditType: .manual,
  isAutoReward: false,
  rewardPoints: 100,
  rewardPromoCodes: nil,
  userId: "1",
  isTop: false,
  recommendTag: "推荐",
  recommendDesc: "推荐描述",
  pubMode: .pro
)
