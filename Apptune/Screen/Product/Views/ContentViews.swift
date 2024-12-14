import SwiftUI

struct JoinedActiveView: View {
  @EnvironmentObject private var acticeService: ActiveService
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        if $acticeService.joinedActives.isEmpty {
          EmptyView(text: "你还没有参加任何活动")
            .padding(.horizontal)
        }

        ForEach(acticeService.joinedActives) { ac in
          ActiveCard(
            title: ac.title,
            description: ac.description,
            startAt: ac.startAt,
            endAt: ac.endAt,
            joinCount: ac.joinCount ?? 0,
            status: ac.status,
            cover: ac.cover,
            productName: ac.productName,
            productLogo: ac.productLogo
          )
        }
      }
      .padding(.horizontal)
    }
  }
}

struct MyProductsView: View {
  @EnvironmentObject private var productService: ProductService

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(productService.selfProducts) { product in
          ProductCard(
            title: product.name,
            description: product.description,
            stars: 0,
            category: product.category,
            logo: product.icon,
            developer: product.developer ?? "",
            status: product.status ?? 1
          )
        }

        if productService.selfProducts.isEmpty {
          EmptyView(text: "快发布一个产品吧")
            .padding(.horizontal)
        }
      }
      .padding(.horizontal)
    }
  }
}

struct MyActicesView: View {
  @EnvironmentObject private var acticeService: ActiveService
  @EnvironmentObject var router: Router

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        if acticeService.selfActives.isEmpty {
          EmptyView(text: "快新建一个活动吧")
            .padding(.horizontal)
        } else {
          ForEach(acticeService.selfActives) { ac in
            ActiveCard(
              title: ac.title,
              description: ac.description,
              startAt: ac.startAt,
              endAt: ac.endAt,
              joinCount: ac.joinCount ?? 0,
              status: ac.status,
              cover: ac.cover,
              productName: ac.productName,
              productLogo: ac.productLogo
            )
            .onTapGesture {
              router.navigate(to: .activeDetail(active: ac))
            }
          }
        }
      }
      .padding(.horizontal)
    }
  }
}
