import Foundation

// 产品相关的服务类
class ProductService: ObservableObject {
//    static let shared = ProductService()
    
    @Published var selfProducts: [ProductInfo] = []
    
    @Published var isLoading = false
    @Published var totalMyProducts: Int = 0
    
    private var currentPage = 1
    private let pageSize = 150
    
    var hasMoreProducts: Bool {
        selfProducts.count < totalMyProducts
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        NoticeManager.shared.openNotice(open: .toast(error.localizedDescription))
        isLoading = false
    }

    
    func loadProducts(refresh: Bool = false) async {
        guard !isLoading else { return }
        if refresh {
            currentPage = 1
        }
        
        isLoading = true
        do {
            let response =  try await ProductAPI.shared.getSelfProductList(
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
            await handleError(error)
        }
    }
    
    func refreshAll() async {
        await loadProducts(refresh: true)
    }
    
}
