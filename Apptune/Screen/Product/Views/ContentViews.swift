import SwiftUI

struct JoinedActiveView: View {
    @EnvironmentObject private var acticeService: ActiveService
    var body: some View {
        LazyVStack(spacing: 16) {
            if $acticeService.joinedActives.isEmpty {
                EmptyView(text: "你还没有参加任何活动")
                    .padding(.horizontal)
            }

            ForEach(acticeService.joinedActives) { ac in
                ActiveCard(
                    title: ac.title,
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
                        developer: product.developer ?? ""
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
    var body: some View {
        LazyVStack(spacing: 16) {
            if acticeService.selfActives.isEmpty {
                EmptyView(text: "快新建一个活动吧")
                    .padding(.horizontal)
            } else {
                ForEach(acticeService.selfActives) { ac in
                    ActiveCard(
                        title: ac.title,
                        date: ac.startAt.description,
                        joined: 56,
                        status: ac.status,
                        cover: ac.cover,
                        organizer: ac.smallCover
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
