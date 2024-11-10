import Foundation

@MainActor
class ProductViewModel: ObservableObject {
  @Published var myProducts: [ProductInfo] = []
  @Published var myEvents: [EventInfo] = []
  @Published var joinedEvents: [EventInfo] = []
  @Published var isLoading = false
  @Published var totalMyProducts: Int = 0
  @Published var totalMyEvents: Int = 0
  @Published var totalJoinedEvents: Int = 0

  private var currentMyPage = 1
  private var currentFollowedPage = 1
  private let pageSize = 150

  // 添加一些辅助计算属性
  var hasMoreMyProducts: Bool {
    myProducts.count < totalMyProducts
  }

  private func handleError(_ error: Error) {
    NoticeManager.shared.openNotice(open: .toast(error.localizedDescription))
    isLoading = false
  }

  func loadMyProducts(refresh: Bool = false) async {
    guard !isLoading else { return }
    if refresh {
      currentMyPage = 1
    }

    isLoading = true
    do {
      let response = try await ProductAPI.shared.getProductList(
        page: currentMyPage,
        pageSize: pageSize
      )
      if refresh {
        myProducts = response.items
      } else {
        myProducts.append(contentsOf: response.items)
      }
      totalMyProducts = response.total
      currentMyPage += 1
      isLoading = false
    } catch {
      handleError(error)
    }
  }

  func refreshAll() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.loadMyProducts(refresh: true) }
    }
  }
}
