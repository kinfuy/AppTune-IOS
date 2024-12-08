import SwiftUI

struct PromoCodeList: View {
  let codes: [String]
  let onRemove: (String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // 总计显示
      HStack {
        Text("已添加优惠码")
          .font(.system(size: 14))
          .foregroundColor(.gray)
        Text("\(codes.count)")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.blue)
        Text("个")
          .font(.system(size: 14))
          .foregroundColor(.gray)
        Spacer()
      }
      .padding(.horizontal, 16)

      // 优惠码列表
      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(codes, id: \.self) { code in
            HStack {
              Text(code)
                .font(.system(size: 14))
              Spacer()
              Button(action: { onRemove(code) }) {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(.gray)
              }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
          }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
      }
      .frame(maxHeight: 200)
    }
  }
}
