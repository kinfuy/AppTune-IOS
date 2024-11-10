import SwiftUI

struct ProductCard: View {
  let title: String
  let description: String
  let stars: Int
  let category: String
  let logo: String
  let developer: String

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

          Text(developer)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .lineLimit(1)
        }

        Spacer()

        Text(category)
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
        Label("\(stars)", systemImage: "heart")
          .font(.system(size: 12))
          .foregroundColor(.pink)
          
        Spacer()
        
        Label("审核中", systemImage: "lock")
            .font(.system(size: 12))
            .foregroundColor(.orange)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
  }
}


#Preview {
    ProductCard(title: "suka", description: "测试文案", stars: 11, category: "测试", logo: "user", developer: "杨杨杨")
}
