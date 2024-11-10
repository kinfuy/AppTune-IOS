import SwiftUI

struct JoinedEventsView: View {
  @EnvironmentObject private var viewModel: ProductViewModel
  var body: some View {
    LazyVStack(spacing: 16) {
      if viewModel.joinedEvents.isEmpty && !viewModel.isLoading {
        EmptyView(text: "你还没有参加任何活动")
          .padding(.horizontal)
      }

      ForEach(viewModel.joinedEvents) { ac in
        EventCard(
          title: ac.name,
          date: ac.startAt.description,
          joined: 56,
          status: ac.status,
          cover: ac.cover,
          organizer: ac.smallCover
        )
      }
    }
    .padding(.horizontal)
  }
}

//struct FollowedProductsView: View {
//    var body: some View {
//        LazyVStack(spacing: 16) {
//            ForEach(0 ..< 5) { _ in
//                ProductCard(
//                    title: "SwiftUI Helper",
//                    description: "SwiftUI 开发辅助工具，提供丰富的组件和实用工具，帮助开发者快速构建优秀的 iOS 应用",
//                    stars: 256,
//                    category: "开发工具",
//                    logo: "logo",
//                    developer: "AppTune Team"
//                )
//            }
//        }
//        .padding(.horizontal)
//    }
//}

struct MyProductsView: View {
  @EnvironmentObject private var viewModel: ProductViewModel

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(viewModel.myProducts) { product in
          ProductCard(
            title: product.name,
            description: product.description,
            stars: 0,
            category: product.category,
            logo: product.icon,
            developer: product.developer ?? ""
          )
        }

        if viewModel.myProducts.isEmpty && !viewModel.isLoading {
          EmptyView(text: "快发布一个产品吧")
            .padding(.horizontal)
        }
      }
      .padding(.horizontal)
    }
  }
}

struct MyEventsView: View {
  @EnvironmentObject private var viewModel: ProductViewModel
  var body: some View {
    LazyVStack(spacing: 16) {
      if viewModel.myEvents.isEmpty && !viewModel.isLoading {
        EmptyView(text: "快新建一个活动吧")
          .padding(.horizontal)
      }

      ForEach(viewModel.myEvents) { ac in
        EventCard(
          title: ac.name,
          date: ac.startAt.description,
          joined: 56,
          status: ac.status,
          cover: ac.cover,
          organizer: ac.smallCover
        )
      }
    }
    .padding(.horizontal)
  }
}
