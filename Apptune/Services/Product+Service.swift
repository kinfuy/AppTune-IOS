import Foundation

// 产品相关的服务类
class ProductService: ObservableObject {
  static let shared = ProductService()

  @Published var allProducts: [ProductInfo] = []
  @Published var selfProducts: [ProductInfo] = []
  @Published var pendingProductReviews: [ProductInfo] = []

  @Published var selfPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var allPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var pendingPage = Page(page: 1, pageSize: 150, total: 0, loading: false)

  @MainActor
  func loadProducts(refresh: Bool = false) async {
    guard !selfPage.loading else { return }
    if refresh {
      selfPage.page = 1
    }

    selfPage.loading = true
    do {
      let response = try await API.getSelfProductList(
        page: selfPage.page,
        pageSize: selfPage.pageSize
      )

      if refresh {
        selfProducts = response.items
      } else {
        selfProducts.append(contentsOf: response.items)
      }
      selfPage.total = response.total
      selfPage.page += 1
      selfPage.loading = false
    } catch {
      selfPage.loading = false
    }
  }

  // 没有才获取
  @MainActor
  func load() async {
    if selfPage.total == 0 {
      await loadProducts(refresh: true)
    }
  }

  @MainActor
  func loadPendingProductReviews() async {
    guard !pendingPage.loading else { return }
    pendingPage.loading = true
    do {
      // 获取待审核产品列表,不需要分页
      let response = try await API.getAuditProductList()
      pendingProductReviews = response.items
    } catch {
      pendingPage.loading = false
    }
  }

  @MainActor
  func review(id: String, status: Int) async {
    do {
      try await API.auditProduct(id: id, status: status)
    } catch {
      print(error)
    }
  }

  @MainActor
  func loadAllProductList(refresh: Bool = false) async {
    guard !allPage.loading else { return }
    if refresh {
      allPage.page = 1
    }
    allPage.loading = true
    do {
      let response = try await API.getProductList(page: allPage.page, pageSize: allPage.pageSize)
      if refresh {
        allProducts = response.items
      } else {
        allProducts.append(contentsOf: response.items)
      }
      allPage.total = response.total
      allPage.page += 1
      allPage.loading = false
    } catch {
      print(error)
    }
  }

  @MainActor
  func deleteProduct(id: String, success: @escaping () -> Void, failure: @escaping () -> Void) async
  {
    do {
      try await API.deleteProduct(id: id)
      await loadProducts(refresh: true)
      success()
    } catch {
      failure()
    }
  }
}
