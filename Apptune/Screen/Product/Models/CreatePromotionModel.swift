import Foundation

// 数据模型
struct CreatePromotionModel: Codable {
  let productId: String
  let groupName: String
  let promoCodes: [String]

  enum CodingKeys: String, CodingKey {
    case productId = "product_id"
    case groupName = "group_name"
    case promoCodes = "promo_codes"
  }
}

// ViewModel
@MainActor
class CreatePromotionViewModel: ObservableObject {
  // 表单数据
  @Published var selectedProduct: ProductInfo?
  @Published var groupName: String = ""
  @Published var promoCodes: [String] = []

  // 状态
  @Published var isLoading: Bool = false

  func checkValid() -> String? {
    if selectedProduct == nil {
      return "请选择产品"
    }
    if groupName.isEmpty {
      return "请输入分组名称"
    }
    if promoCodes.isEmpty {
      return "请输入促销码"
    }
    return nil
  }

  // 促销码处理
  func addPromoCodes(_ codes: [String]) {
    let validCodes =
      codes
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty && validatePromoCode($0) }

    promoCodes = Array(Set(promoCodes + validCodes)).sorted()
  }

  func removePromoCode(_ code: String) {
    promoCodes.removeAll { $0 == code }
  }

  // CSV处理
  func processCSVContent(_ content: String?) {
    guard let content = content else { return }
    let codes = validateCSVContent(content)
    addPromoCodes(codes)
  }

  // 创建促销码
  @MainActor
  func createPromotion() async {
    isLoading = true
    defer { isLoading = false }

    do {
      try await PromotionAPI.shared.createPromotion(
        productId: selectedProduct!.id, codes: promoCodes, group: groupName)
      isLoading = false
      Router.shared.toTabBar(.product, isShowModules: true)
    } catch {
      isLoading = false
    }
  }

  // 辅助方法
  private func validateCSVContent(_ content: String) -> [String] {
    return
      content
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }

  private func validatePromoCode(_ code: String) -> Bool {
    // 促销码验证规则
    return code.count >= 3 && code.count <= 20
  }
}
