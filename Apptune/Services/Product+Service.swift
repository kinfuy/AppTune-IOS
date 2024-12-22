import Foundation

// 产品相关的服务类
class ProductService: ObservableObject {
    static let shared = ProductService()

    @Published var selfProducts: [ProductInfo] = []
    @Published var pendingProductReviews: [ProductInfo] = []

    @Published var isLoading = false
    @Published var totalMyProducts: Int = 0

    private var currentPage = 1
    private let pageSize = 150

    var hasMoreProducts: Bool {
        selfProducts.count < totalMyProducts
    }

    @MainActor
    func loadProducts(refresh: Bool = false) async {
        guard !isLoading else { return }
        if refresh {
            currentPage = 1
        }

        isLoading = true
        do {
            let response = try await ProductAPI.shared.getSelfProductList(
                page: currentPage,
                pageSize: pageSize
            )

            if refresh {
                selfProducts = response.items
            } else {
                selfProducts.append(contentsOf: response.items)
            }
            totalMyProducts = response.total
            currentPage += 1
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    // 没有才获取
    @MainActor
    func load() async {
        if totalMyProducts == 0 {
            await loadProducts(refresh: true)
        }
    }

    @MainActor
    func loadPendingProductReviews() async {
        do {
            // 获取待审核产品列表,不需要分页
            let response = try await ProductAPI.shared.getAuditProductList()
            pendingProductReviews = response.items
        } catch {
            isLoading = false
        }
    }

    @MainActor
    func review(id: String, status: Int) async {
        do {
            try await ProductAPI.shared.auditProduct(id: id, status: status)
        } catch {
            print(error)
        }
    }
}
