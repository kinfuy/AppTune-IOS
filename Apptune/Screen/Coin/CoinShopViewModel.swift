import Foundation

struct ShopItem: Identifiable {
  let id: String
  let title: String
  let description: String
  let coin: Int
  let image: String
}

@MainActor
class CoinShopViewModel: ObservableObject {
  @Published var items: [ShopItem] = []
  @Published var userCoin: Int = 0
  @Published var showExchangeAlert = false
  @Published var exchangeMessage = ""

  init() {
    Task {
      await fetchItems()
      await fetchUserCoin()
    }
  }

  func fetchItems() async {
    // TODO: 从服务器获取商品列表
    items = [
     
    ]
  }

  func fetchUserCoin() async {
    userCoin = 0
  }

  func exchange(_ item: ShopItem) {
    if userCoin < item.coin {
      exchangeMessage = "积分不足"
      showExchangeAlert = true
      return
    }

    // TODO: 调用兑换接口
    userCoin -= item.coin
    exchangeMessage = "兑换成功"
    showExchangeAlert = true
  }
}
