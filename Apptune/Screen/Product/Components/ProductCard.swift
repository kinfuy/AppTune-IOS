import SwiftUI

// 创建一个 ObservableObject 来管理每个卡片的状态
class ProductCardState: ObservableObject {
  @Published var showDeveloper = false
}

struct ProductCard: View {
  let title: String
  let description: String
  let stars: Int
  let category: Catalog
  let logo: String
  let developer: String
  let publisher: String
  let status: Int

  // 使用 StateObject 确保每个卡片实例有自己的状态
  @StateObject private var cardState = ProductCardState()

  var statusInfo: (String, Color) {
    switch status {
    case 1:
      return ("审核中", .orange)
    case 3:
      return ("已拒绝", .red)
    default:
      return ("已通过", .green)
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        ImgLoader(logo)
          .frame(width: 48, height: 48)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.gray.opacity(0.1), lineWidth: 1)
          )

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.system(size: 16, weight: .medium))
            .lineLimit(1)

          if developer == publisher {
            Text(publisher)
              .font(.system(size: 12))
              .foregroundColor(.gray)
              .lineLimit(1)
          } else {
            VStack(alignment: .leading, spacing: 2) {
              HStack {
                Text("发布者：")
                  .font(.system(size: 12))
                  .foregroundColor(.gray)
                  .lineLimit(1)
                Text(publisher)
                  .font(.system(size: 12))
                  .foregroundColor(.gray)
                  .lineLimit(1)

                if !cardState.showDeveloper && developer != "" {
                  Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
                }
              }
              .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                  cardState.showDeveloper.toggle()
                }
              }

              if cardState.showDeveloper && developer != "" {
                HStack {
                  Text("开发者：\(developer)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                  Image(systemName: "chevron.up.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
                }
                .onTapGesture {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    cardState.showDeveloper.toggle()
                  }
                }
              }
            }
          }
        }

        Spacer()

        Text(category.label)
          .font(.system(size: 12))
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.theme.opacity(0.1))
          .foregroundColor(.theme)
          .cornerRadius(4)
      }

      Text(description)
        .font(.system(size: 14))
        .foregroundColor(.gray)
        .lineLimit(3)
      HStack(spacing: 16) {
        Spacer()

        if status != 2 {
          Text(statusInfo.0)
            .font(.system(size: 12))
            .foregroundColor(statusInfo.1)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
  }
}

#Preview {
  ProductCard(
    title: "suka", description: "测试文案", stars: 11, category: .effect, logo: "user",
    developer: "杨杨杨", publisher: "杨杨1杨", status: 2)
}
