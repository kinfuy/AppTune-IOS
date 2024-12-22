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
    @Published var duplicateCodes: Set<String> = []

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
        if !duplicateCodes.isEmpty {
            return "存在重复的促销码"
        }
        return nil
    }

    // 促销码处理
    func addPromoCodes(_ newCodes: [String]) {
        // 过滤空字符串
        let filteredCodes = newCodes.filter { !$0.isEmpty }

        // 直接添加所有码
        promoCodes.append(contentsOf: filteredCodes)

        // 如果已选择产品，检查重复
        if let productId = selectedProduct?.id {
            Task {
                do {
                    let duplicates = try await PromotionAPI.shared.checkPromoCodes(
                        filteredCodes, productId: productId)
                    DispatchQueue.main.async {
                        // 只更新重复状态，不移除重复码
                        self.duplicateCodes = self.duplicateCodes.union(duplicates)
                    }
                } catch {
                    print("检查促销码失败:", error)
                }
            }
        }
    }

    func removePromoCode(_ code: String) {
        // 从促销码列表中移除
        promoCodes.removeAll { $0 == code }
        // 从重复码集合中移除
        duplicateCodes.remove(code)
    }

    // CSV处理
    func processCSVContent(_ content: String?) {
        guard let content = content else { return }
        let codes = validateCSVContent(content)
        addPromoCodes(codes)
    }

    // 创建促销码
    @MainActor
    func createPromotion(success: (() -> Void)?) async {
        isLoading = true
        defer { isLoading = false }

        // 创建前检查是否有重复码
        if !duplicateCodes.isEmpty {
            // 这里可以添加错误提示逻辑
            return
        }

        do {
            try await PromotionAPI.shared.createPromotion(
                productId: selectedProduct!.id,
                codes: promoCodes,
                group: groupName)
            if let success = success {
                success()
            }
        } catch {
            // 处理错误
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

    // 建议添加一个新的方法来检查重复码
    func checkDuplicateCode(_ code: String) -> Bool {
        return promoCodes.contains(code)
    }

    // ��加产品选择时的验证
    func setSelectedProduct(_ product: ProductInfo) {
        selectedProduct = product

        // 当选择产品时,验证已有的促销码
        if !promoCodes.isEmpty {
            Task {
                do {
                    let duplicates = try await PromotionAPI.shared.checkPromoCodes(
                        promoCodes, productId: product.id)
                    DispatchQueue.main.async {
                        // 只更新重复状态，不移除重复码
                        self.duplicateCodes = Set(duplicates)
                    }
                } catch {
                    print("检查促销码失败:", error)
                }
            }
        }
    }
}
