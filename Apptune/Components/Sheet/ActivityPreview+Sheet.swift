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

          RewardContentView(
            rewardType: active.rewardType, reward: active.reward, rewardPoints: active.rewardPoints)
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
  let rewardPoints: Int?

  var body: some View {
    HStack(spacing: 16) {
      // 左侧图标区域
      Circle()
        .fill(rewardType.themeColor.opacity(0.1))
        .frame(width: 44, height: 44)
        .overlay(
          Image(systemName: rewardType.iconName)
            .font(.system(size: 20))
            .foregroundColor(rewardType.themeColor)
        )

      // 右侧内容区域
      VStack(alignment: .leading, spacing: 6) {
        if case .points = rewardType, let points = rewardPoints {
          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(points)")
              .font(.system(size: 28, weight: .semibold))
              .foregroundColor(rewardType.themeColor)
            Text("积分")
              .font(.system(size: 15))
              .foregroundColor(rewardType.themeColor.opacity(0.8))
          }
        }

        if let reward = reward, reward != "" {
          Text(reward)
            .font(.system(size: 15))
            .foregroundColor(.primary)
            .lineLimit(2)
        }

        Text(rewardType.description)
          .font(.system(size: 13))
          .foregroundColor(.secondary)
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .padding(.horizontal, 16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(UIColor.systemBackground))
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 8, x: 0, y: 2)
    )
  }
}

extension RewardType {
  var iconName: String {
    switch self {
    case .points:
      return "star.fill"  // 更改为星星图标
    case .promoCode:
      return "ticket.fill"
    case .selfManaged:
      return "gift.fill"  // 移除 circle 后缀
    }
  }

  var themeColor: Color {
    switch self {
    case .points:
      return .orange
    case .promoCode:
      return Color(hex: "#007AFF")  // iOS 蓝色
    case .selfManaged:
      return Color(hex: "#FF2D55")  // iOS 粉色
    }
  }

  var description: String {
    switch self {
    case .points:
      return "完成活动可获得积分"
    case .promoCode:
      return "完成活动可获得兑换码"
    case .selfManaged:
      return "请悉知该活动奖励由发布者自行管理发放"
    }
  }
}
