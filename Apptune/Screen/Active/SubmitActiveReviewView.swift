//
//  SubmitActiveReviewView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import PhotosUI
import SwiftUI

struct SubmitActiveReviewView: View {
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var sheet: SheetManager
  var active: ActiveInfo

  @State private var content: String = ""
  @State private var images: [String] = []
  @State private var isSubmitting = false
  @State private var historyReviews: [ReviewRecord] = []
  @State private var isLoadingHistory = false
  @State private var hasSubmitted = false

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
    return !content.isEmpty && !isSubmitting
  }

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // 根据是否已提交显示不同内容
          if !hasSubmitted {
            // 审核内容输入部分
            VStack(alignment: .leading, spacing: 12) {
              // 图片上传部分
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

              CustomTextField(
                text: $content,
                placeholder: "活动描述",
                isMultiline: true,
                maxLength: 500
              )
            }
          } else {
            // 显示当前提交的内容
            VStack(alignment: .leading, spacing: 12) {
              Text("当前提交")
                .font(.headline)
                .padding(.horizontal)

              VStack(alignment: .leading, spacing: 12) {
                // 提交的文字内容
                Text(content)
                  .font(.system(size: 15))
                  .foregroundColor(.primary)

                // 提交的图片
                if !images.isEmpty {
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
              .padding()
              .background(Color.white)
              .cornerRadius(12)
              .shadow(color: .gray.opacity(0.05), radius: 8)
              .padding(.horizontal)
            }
          }

          // 历史审核记录部分
          if !historyReviews.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
              Text("历史审核记录")
                .font(.headline)
                .padding(.horizontal)

                ForEach(historyReviews, id: \.reviewerId) { record in
                ReviewRecordCard(record: record)
              }
            }
          }

          // 加载中状态
          if isLoadingHistory {
            HStack {
              Spacer()
              ProgressView()
              Spacer()
            }
            .padding()
          }
        }
        .padding(.horizontal)
        .padding(.top)
      }

      // 只有在未提交时才显示提交按钮
      if !hasSubmitted {
        Button(action: {
          Task {
            await submitReview()
          }
        }) {
          if isSubmitting {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text("提交审核")
          }
        }
        .buttonStyle(.black)
        .frame(height: 48)
        .padding()
        .disabled(!canSubmit)
      }
    }
    .navigationTitle("审核")
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

        await loadHistoryReviews()
      }
    }
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
struct ReviewRecord:  Codable {
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
      )
    )
    .environmentObject(ActiveService())
    .environmentObject(Router())
    .environmentObject(NoticeManager())
  }
}
