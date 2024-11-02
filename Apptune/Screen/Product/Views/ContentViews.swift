import SwiftUI

struct JoinedEventsView: View {
  var body: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<5) { _ in
        EventCard(
          title: "Swift 开发者大会",
          date: "2024-05-20",
          location: "上海",
          participants: 128,
          status: "进行中",
          cover: "empty",
          organizer: "logo"
        )
      }
    }
    .padding(.horizontal)
  }
}

struct FollowedProductsView: View {
  var body: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<5) { _ in
        ProductCard(
          title: "SwiftUI Helper",
          description: "SwiftUI 开发辅助工具，提供丰富的组件和实用工具，帮助开发者快速构建优秀的 iOS 应用",
          stars: 256,
          category: "开发工具",
          logo: "logo",
          developer: "AppTune Team"
        )
      }
    }
    .padding(.horizontal)
  }
}

struct MyProductsView: View {
  var body: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<5) { _ in
        ProductCard(
          title: "SwiftUI Helper",
          description: "SwiftUI 开发辅助工具，提供丰富的组件和实用工具，帮助开发者快速构建优秀的 iOS 应用",
          stars: 256,
          category: "开发工具",
          logo: "logo",
          developer: "logo"
        )
      }
    }
    .padding(.horizontal)
  }
}

struct MyEventsView: View {
  var body: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<5) { _ in
        EventCard(
          title: "iOS 技术沙龙",
          date: "2024-04-15",
          location: "北京",
          participants: 56,
          status: "报名中",
          cover: "empty",
          organizer: "logo"
        )
      }
    }
    .padding(.horizontal)
  }
}
