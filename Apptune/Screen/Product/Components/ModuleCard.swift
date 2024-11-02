import SwiftUI

struct ModuleCard: View {
  let title: String
  let icon: String
  let count: Int
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: icon)
            .font(.system(size: 28))
            .foregroundColor(color)
          Spacer()
          Text("\(count)")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.gray)
        }

        Text(title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.black)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.white)
          .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      )
    }
  }
}
