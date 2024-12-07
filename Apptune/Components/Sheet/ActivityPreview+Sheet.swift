import SwiftUI

struct ActivityPreviewSheet: View {
  let product: ProductInfo?
  let title: String
  let description: String
  let images: [String]
  let limit: Int?
  let endAt: Date?
  let isAutoEnd: Bool
  let publishMode: PublishMode

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // 产品信息预览
        if let product = product {
          HStack(spacing: 16) {
            ImgLoader(product.icon)
              .frame(width: 48, height: 48)
              .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
              Text(product.name)
                .font(.headline)
              Text(product.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
            }
            Spacer()
          }
          .padding()
          .background(Color.white)
          .cornerRadius(12)
        }

        // 活动信息预览
        VStack(alignment: .leading, spacing: 16) {
          Text("活动预览")
            .font(.headline)
            .foregroundColor(Color(hex: "#666666"))

          VStack(alignment: .leading, spacing: 12) {
            // 标题
            if !title.isEmpty {
              Text(title)
                .font(.title2)
                .bold()
            }

            // 图片
            if !images.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                  ForEach(images, id: \.self) { image in
                    ImgLoader(image)
                      .frame(width: 200, height: 200)
                      .clipped()
                      .cornerRadius(8)
                  }
                }
              }
            }

            // 描述
            if !description.isEmpty {
              Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            }

            // 专业模式额外信息
            if publishMode == .pro {
              Divider()

              // 人数限制
              if let limit = limit, limit > 0 {
                HStack {
                  Text("参与人数限制:")
                  Text("\(limit)人")
                    .foregroundColor(.secondary)
                }
              }

              // 结束时间
              if isAutoEnd, let endAt = endAt {
                HStack {
                  Text("结束时间:")
                  Text(endAt, style: .date)
                    .foregroundColor(.secondary)
                }
              }
            }
          }
          .padding()
          .background(Color.white)
          .cornerRadius(12)
        }
      }
      .padding()
    }
  }
}
