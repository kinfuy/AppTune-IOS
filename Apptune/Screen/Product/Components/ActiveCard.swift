import SwiftUI

struct ActiveCard: View {
  let title: String
  let date: String
  let joined: Int
  let status: Int
  let cover: String
  let organizer: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ZStack(alignment: .bottomLeading) {
        ImgLoader(cover)
          .frame(height: 120)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .fill(
                LinearGradient(
                  colors: [.black.opacity(0.3), .clear],
                  startPoint: .bottom,
                  endPoint: .top
                )
              )
          )

        Text(status.description)
          .font(.system(size: 12))
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.theme)
          .foregroundColor(.white)
          .cornerRadius(4)
          .padding(8)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(.system(size: 16, weight: .medium))
          .lineLimit(1)

        HStack {
          ImgLoader(organizer)
            .frame(width: 20, height: 20)
            .clipShape(Circle())
          Text(organizer)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .lineLimit(1)
        }

        HStack(spacing: 16) {
          Label(date, systemImage: "calendar")
          Label("\(joined)人参与", systemImage: "person.2")
        }
        .font(.system(size: 12))
        .foregroundColor(.gray)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
  }
}
