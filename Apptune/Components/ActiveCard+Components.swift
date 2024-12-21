import SwiftUI

struct ActiveCard: View {
    // 基于 ActiveInfo 模型调整属性
    let title: String
    let description: String
    let startAt: Date
    let endAt: Date?
    let joinCount: Int
    let status: Int // 活动状态
    let cover: String
    let productName: String // 产品名称作为组织者
    let productLogo: String // 产品logo作为组织者头像
    
  

    // 格式化日期
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: startAt))"
    }

    // 获取状态文本
    private var statusText: String {
        switch status {
        case 1: return "待审核"
        case 2: return "进行中"
        case 3: return "已结束"
        case 4: return "已拒绝"
        default: return "未知"
        }
    }

    // 获取状态颜色
    private var statusColor: Color {
        switch status {
        case 1: return .orange
        case 2: return .theme
        case 3: return .gray
        case 4: return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // 顶部图片和标题部分
            VStack {
                ImgLoader(cover)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#333333"))
                            .lineLimit(2)

                        Spacer()
                    }
                    // 描述文本
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#999999"))
                        .lineLimit(2)
                    // 状态标签
                    Text(statusText)
                        .font(.system(size: 14))
                        .colorTag(statusColor)

                    // 日期范围
                    Text(dateRangeText)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            // 底部信息栏
            HStack {
                // 产品信息
                HStack {
                    ImgLoader(productLogo)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    Text(productName)
                        .font(.system(size: 14))
                        .foregroundColor(.theme)
                }

                Spacer()

                // 参与人数
//                Text("已有 \(String(describing: joinCount)) 人参与")
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 进行中活动预览
        ActiveCard(
            title: "SwiftUI 开发者线下交流会",
            description: "遇见开发者，分享技术心得，结交志同道合的朋友",
            startAt: Date(),
            endAt: Date().addingTimeInterval(7 * 24 * 60 * 60),
            joinCount: 42,
            status: 1,
            cover: "app",
            productName: "Suka",
            productLogo: "logo"
        )

        // 已结束活动预览
        ActiveCard(
            title: "iOS 应用架构设计研讨会",
            description: "深入探讨 iOS 应用架构设计的最佳实践",
            startAt: Date().addingTimeInterval(-14 * 24 * 60 * 60),
            endAt: Date().addingTimeInterval(-7 * 24 * 60 * 60),
            joinCount: 86,
            status: 2,
            cover: "app",
            productName: "Suka",
            productLogo: "logo"
        )
    }
    .padding()
    .background(Color(hex: "#F5F5F5"))
}
