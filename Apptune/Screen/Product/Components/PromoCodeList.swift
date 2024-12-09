import SwiftUI

struct PromoCodeList: View {
  let codes: [String]
  let duplicateCodes: Set<String>
  let onRemove: (String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(codes, id: \.self) { code in
        HStack {
          Text(code)
            .foregroundColor(duplicateCodes.contains(code) ? .red : .primary)

          Spacer()

          if duplicateCodes.contains(code) {
            Text("已存在")
              .font(.caption)
              .foregroundColor(.red)
          }

          Button(action: {
             onRemove(code)
          }) {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.gray)
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())
          }
          .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
      }
    }
  }
}
