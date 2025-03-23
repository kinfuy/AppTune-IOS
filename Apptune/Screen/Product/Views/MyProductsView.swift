import SwiftUI

struct MyProductsView: View {
  @EnvironmentObject private var productService: ProductService
  @EnvironmentObject private var notice: NoticeManager
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
                .contextMenu {
                  Button(role: .destructive) {
                    notice.open(
                      open: .confirm(
                        Confirm(
                          title: "删除产品",
                          desc: "确认删除产品「\(product.name)」吗？",
                          onSuccess: {
                            Tap.shared.play(.light)
                            Task {
                              await productService.deleteProduct(id: product.id, success: {
                                notice.open(open: .toast("删除成功"))
                              }, failure: {
                                notice.open(open: .toast("删除失败"))
                              })
                            }
                          })))

                  } label: {
                    Label("删除", systemImage: "trash")
                  }

                  Button {
                    router.navigate(to: .publishProduct(product: product))
                  } label: {
                    Label("编辑", systemImage: "pencil")
                  }
                }
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
