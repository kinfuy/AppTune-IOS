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
      ShopItem(id: "1", title: "会员月卡", description: "享受30天会员特权", coin: 1000, image: "crown.fill"),
      ShopItem(
        id: "2", title: "主题换肤", description: "解锁精美主题皮肤", coin: 500, image: "paintpalette.fill"),
      ShopItem(id: "3", title: "特效动画", description: "解锁炫酷特效动画", coin: 300, image: "sparkles"),
      ShopItem(
        id: "4", title: "头像框", description: "专属头像装饰框", coin: 200, image: "person.crop.square.fill"),
    ]
  }

  func fetchUserCoin() async {
    // TODO: 获取用户积分
    userCoin = 1500
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
