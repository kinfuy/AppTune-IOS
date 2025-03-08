import Foundation
import StoreKit

// MARK: - 错误类型
enum CoinError: LocalizedError {
  case invalidProduct
  case purchaseFailed
  case verificationFailed
  case insufficientBalance
  case invalidAmount

  var errorDescription: String? {
    switch self {
    case .invalidProduct:
      return "无效的商品"
    case .purchaseFailed:
      return "购买失败"
    case .verificationFailed:
      return "验证失败"
    case .insufficientBalance:
      return "余额不足"
    case .invalidAmount:
      return "无效的金额"
    }
  }
}

// MARK: - 积分服务
@MainActor
class CoinService: ObservableObject {
  static let shared = CoinService()

  // 当前余额
  @Published private(set) var balance: Int = 0

  // 商品配置
  private let productIdentifiers = [
    "com.apptune.coin.100",
    "com.apptune.coin.500",
    "com.apptune.coin.1000",
    "com.apptune.coin.2000",
  ]

  private var products: [Product] = []
  private var updates: Task<Void, Never>? = nil

  private init() {
    // 开始监听交易更新
    updates = observeTransactionUpdates()

    // 加载商品信息
    Task {
      await loadProducts()
    }

    // 从本地恢复余额
    balance = UserDefaults.standard.integer(forKey: "coin_balance")
  }

  deinit {
    updates?.cancel()
  }

  // MARK: - Public Methods

  /// 获取可购买的商品列表
  func getProducts() -> [Product] {
    return products
  }

  /// 购买商品
  func purchase(_ product: Product) async throws {
    let result = try await product.purchase()

    switch result {
    case .success(let verification):
      // 验证购买凭证
      switch verification {
      case .verified(let transaction):
        // 更新余额
        await processPurchase(transaction)
        // 完成交易
        await transaction.finish()
      case .unverified:
        throw CoinError.verificationFailed
      }
    case .userCancelled:
      return
    case .pending:
      return
    @unknown default:
      throw CoinError.purchaseFailed
    }
  }

  /// 消费积分
  func consume(amount: Int) throws {
    guard amount > 0 else {
      throw CoinError.invalidAmount
    }

    guard balance >= amount else {
      throw CoinError.insufficientBalance
    }

    balance -= amount
    saveBalance()
  }

  /// 增加积分
  func add(amount: Int) {
    guard amount > 0 else { return }
    balance += amount
    saveBalance()
  }

  // MARK: - Private Methods

  /// 加载商品信息
  private func loadProducts() async {
    do {
      products = try await Product.products(for: productIdentifiers)
    } catch {
      print("Failed to load products:", error)
    }
  }

  /// 处理购买
  private func processPurchase(_ transaction: Transaction) async {
    // 根据商品ID增加相应积分
    let coinAmount: Int
    switch transaction.productID {
    case "com.apptune.coin.100":
      coinAmount = 100
    case "com.apptune.coin.500":
      coinAmount = 500
    case "com.apptune.coin.1000":
      coinAmount = 1000
    case "com.apptune.coin.2000":
      coinAmount = 2000
    default:
      coinAmount = 0
    }

    add(amount: coinAmount)

    // 同步到服务器
    do {
      try await syncToServer(transaction)
    } catch {
      print("Failed to sync transaction:", error)
    }
  }

  /// 观察交易更新
  private func observeTransactionUpdates() -> Task<Void, Never> {
    Task(priority: .background) {
      for await verification in Transaction.updates {
        // 处理交易更新
        switch verification {
        case .verified(let transaction):
          await processPurchase(transaction)
          await transaction.finish()
        case .unverified:
          break
        }
      }
    }
  }

  /// 保存余额到本地
  private func saveBalance() {
    UserDefaults.standard.set(balance, forKey: "coin_balance")
  }

  /// 同步交易到服务器
  private func syncToServer(_ transaction: Transaction) async throws {
    // 构建同步参数
    let params: [String: Any] = [
      "productId": transaction.productID,
      "transactionId": transaction.id,
      "originalTransactionId": transaction.originalID,
      "purchaseDate": transaction.purchaseDate.timeIntervalSince1970,
    ]

    // 调用API同步
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/coin/sync",
      method: "POST",
      body: params
    )

    let _: VoidCodable = try await API.shared.session.data(for: request)
  }
}

// MARK: - 便利扩展
extension Product {
  /// 获取商品对应的积分数量
  var coinAmount: Int {
    switch id {
    case "com.apptune.coin.100":
      return 100
    case "com.apptune.coin.500":
      return 500
    case "com.apptune.coin.1000":
      return 1000
    case "com.apptune.coin.2000":
      return 2000
    default:
      return 0
    }
  }
}
