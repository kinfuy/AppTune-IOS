import SwiftUI

struct ActivityPreviewSheet: View {
  let active: ActiveInfo

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // 头部区域
        VStack(alignment: .leading, spacing: 12) {
          // 图片轮播
          if !active.images.isEmpty {
            TabView {
              ForEach(active.images, id: \.self) { imageUrl in
                ImgLoader(imageUrl)
                  .frame(height: 400)
                  .clipped()
              }
            }
            .frame(height: 400)
            .tabViewStyle(PageTabViewStyle())
          }

          // 活动标题和产品信息
          VStack(alignment: .leading, spacing: 16) {
            // 标题部分
            Text(active.title)
              .font(.title2)
              .fontWeight(.bold)
              .lineSpacing(4)
              .padding(.bottom, 4)

            // 产品信息部分
            HStack(spacing: 12) {
              ImgLoader(active.productLogo)
                .frame(width: 38, height: 38)
                .cornerRadius(all: 8)
              Text(active.productName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
              Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
              if let endAt = active.endAt {
                HStack(spacing: 6) {
                  Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                  Text("截止至 \(endAt.formatted())")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
              }

              if let limit = active.limit, limit > 0 {
                HStack(spacing: 6) {
                  Image(systemName: "person.2")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                  Text("\(limit)人可参与")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
              }
            }
            .padding(.top, 4)
          }
          .padding(.horizontal)
        }

        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("活动奖励")
              .font(.headline)
              .fontWeight(.bold)
            Spacer()
          }

          RewardContentView(rewardType: active.rewardType, reward: active.reward)
        }
        .padding()

        // 活动详情
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("活动详情")
              .font(.headline)
              .fontWeight(.bold)
            Spacer()
          }
          HStack {
            Text(active.description)
              .font(.body)
              .foregroundColor(.secondary)
            Spacer()
          }
        }
        .padding()
      }
    }
    .background(Color(hex: "#f4f4f4"))
  }
}

struct RewardContentView: View {
  let rewardType: RewardType
  let reward: String?

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: rewardType.iconName)
        .font(.system(size: 40))
        .foregroundColor(rewardType.themeColor)

      VStack(alignment: .leading, spacing: 8) {
        Text(rewardType.description)
          .font(.system(size: 14))
          .foregroundColor(.secondary)

        if let reward = reward {
          Text(reward)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(rewardType.themeColor)
        }
      }
      Spacer()
    }
    .padding()
    .background(rewardType.themeColor.opacity(0.1))
    .cornerRadius(all: 12)
  }
}

extension RewardType {
  var iconName: String {
    switch self {
    case .points:
      return "dollarsign.circle.fill"
    case .promoCode:
      return "ticket.fill"
    case .selfManaged:
      return "gift.circle.fill"
    }
  }

  var themeColor: Color {
    switch self {
    case .points:
      return .orange
    case .promoCode:
      return .blue
    case .selfManaged:
      return .gray
    }
  }

  var description: String {
    switch self {
    case .points:
      return "完成活动可获得积分"
    case .promoCode:
      return "完成活动可获得兑换码"
    case .selfManaged:
      return "请悉知该活动奖励由发布者自行管理 发放"
    }
  }
}

#Preview {
  ActivityPreviewSheet(
    active: ActiveInfo(
      id: "preview-1",
      title: "新人专享活动",
      description: """
        欢迎加入我们!参与活动即可获得积分奖励。活动期间完成任务最高可得1000积分,可用于兑换商城礼品。

        活动规则:
        1. 首次登录奖励100积分
        2. 每日签到奖励10积分
        3. 邀请好友奖励50积分/人
        4. 完成新手任务奖励200积分
        """,
      cover: "https://picsum.photos/800/400",
      startAt: Date(),
      endAt: Date().addingTimeInterval(7 * 24 * 60 * 60),
      limit: 1000,
      rewardType: .points,
      joinCount: 128,
      likeCount: 56,
      status: 1,
      createTime: Date(),
      productId: "product-1",
      productName: "示例产品",
      productLogo: "https://picsum.photos/100/100",
      images: [
        "https://picsum.photos/400/600",
        "https://picsum.photos/400/600",
        "https://picsum.photos/400/600",
      ],
      tags: [
        TagEntity(name: "新人专享", color: .theme),
        TagEntity(name: "限时活动", color: .orange),
      ],
      link: nil,
      reward: "1000",
      userId: "",
      isTop: false,
      recommendTag: nil,
      recommendDesc: nil
    )
  )
}
