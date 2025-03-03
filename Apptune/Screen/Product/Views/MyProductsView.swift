import SwiftUI

struct MyProductsView: View {
  @EnvironmentObject private var productService: ProductService
  @EnvironmentObject var router: Router

  var isEmpty: Bool {
    productService.selfProducts.isEmpty
  }

  var body: some View {
    Group {
      if productService.selfPage.loading {
        VStack {
          Spacer()
          LoadingComponent()
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 16) {
            if isEmpty {
              EmptyView(text: "快发布一个产品吧")
                .padding(.horizontal)
            } else {
              ForEach(productService.selfProducts) { product in
                ProductCard(
                  title: product.name,
                  description: product.description,
                  stars: 0,
                  category: product.category,
                  logo: product.icon,
                  developer: product.developer ?? "",
                  publisher: product.publisher ?? "",
                  status: product.status ?? 1
                )
              }
            }
          }
          .padding(.horizontal)
        }
      }
    }
    .onAppear {
      Task {
        await productService.loadProducts(refresh: true)
      }
    }
    .customNavigationBar(title: "我的产品", router: router)
  }
}

#Preview("我的产品") {
  MyProductsView()
    .environmentObject(ProductService())
}
