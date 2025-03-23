import SwiftUI

// 定义创建类型
enum CreateType: String, CaseIterable {
  case activity = "活动"
  case product = "产品"
  case promoCode = "促销码"
  case experience = "经验"

  var icon: String {
    switch self {
    case .activity: return "star.circle.fill"
    case .product: return "cube.fill"
    case .promoCode: return "ticket.fill"
    case .experience: return "lightbulb.fill"
    }
  }

  var description: String {
    switch self {
    case .activity: return "创建新的活动或任务"
    case .product: return "添加新的产品或服务"
    case .promoCode: return "生成新的促销码"
    case .experience: return "分享使用经验和技巧"
    }
  }

  var color: Color {
    switch self {
    case .activity: return .blue
    case .product: return .purple
    case .promoCode: return .orange
    case .experience: return .green
    }
  }
}

// 定义推荐模板结构
struct RecommendTemplate: Identifiable {
  let id = UUID()
  let title: String
  let description: String
  let type: CreateType
  let icon: String
}

struct CreateTypeSheet: View {
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var router: Router

  // 推荐模板数据
  private let recommendTemplates: [RecommendTemplate] = []

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: 24) {
          // 主要创建类型
          VStack(alignment: .leading, spacing: 16) {
            Text("选择类型")
              .font(.headline)
              .padding(.horizontal)

            LazyVGrid(
              columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
              ], spacing: 16
            ) {
              ForEach(CreateType.allCases, id: \.self) { type in
                CreateTypeCard(type: type) {
                  handleTypeSelection(type)
                }
              }
            }
            .padding(.horizontal)
          }

          if !recommendTemplates.isEmpty {
            // 推荐模板
            VStack(alignment: .leading, spacing: 16) {
              Text("推荐模板")
                .font(.headline)
                .padding(.horizontal)

              ForEach(recommendTemplates) { template in
                TemplateCard(template: template) {
                  handleTemplateSelection(template)
                }
              }
            }
            .padding(.horizontal)
          }
        }
        .padding(.vertical)
      }
    }
    .background(Color(.systemGroupedBackground))
  }

  private func handleTypeSelection(_ type: CreateType) {
    sheet.close()
    switch type {
    case .activity:
      router.navigate(to: .publishActivity(active: nil))
    case .product:
        router.navigate(to: .publishProduct(product: nil))
    case .promoCode:
      router.navigate(to: .createPromotion)
    case .experience:
      router.navigate(to: .createPost)
    }
  }

  private func handleTemplateSelection(_ template: RecommendTemplate) {
    sheet.close()
    // 根据模板类型处理导航
    switch template.type {
    case .activity:
      router.navigate(to: .createPromotion)
    case .promoCode:
      router.navigate(to: .createPromotion)
    default:
      break
    }
  }
}

// 创建类型卡片组件
struct CreateTypeCard: View {
  let type: CreateType
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: type.icon)
          .font(.system(size: 24))
          .foregroundColor(type.color)

        Text(type.rawValue)
          .font(.headline)
          .foregroundColor(.primary)

        Text(type.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(12)
      .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
  }
}

// 推荐模板卡片组件
struct TemplateCard: View {
  let template: RecommendTemplate
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        Image(systemName: template.icon)
          .font(.system(size: 24))
          .foregroundColor(template.type.color)
          .frame(width: 40, height: 40)
          .background(template.type.color.opacity(0.1))
          .cornerRadius(8)

        VStack(alignment: .leading, spacing: 4) {
          Text(template.title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.primary)

          Text(template.description)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundColor(.gray)
      }
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(12)
      .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
  }
}

#Preview {
  Text("s").sheet(
    isPresented: .constant(true),
    content: {
      CreateTypeSheet()
        .environmentObject(SheetManager())
        .environmentObject(Router())
    })
}
