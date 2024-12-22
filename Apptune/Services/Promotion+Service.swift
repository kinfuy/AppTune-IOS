//
//  Promotion+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import Foundation

// 促销码信息模型
struct PromotionInfo: Codable {
  let productId: String  // 产品ID
  let productName: String  // 产品名称
  let codes: [PromotionCode]  // 促销码列表
}

// 促销码相关的服务类
class PromotionService: ObservableObject {
  static let shared = PromotionService()
  @Published var promotions: [PromotionCode] = []

  @Published var isLoading = false

  // 新增计算属性：按产品分组的促销码
  var groupedPromotions: [String: [PromotionCode]] {
    Dictionary(grouping: promotions) { $0.productId }
  }
    
    
  func getProductPromotions(productId: String) -> [PromotionCode] {
    groupedPromotions[productId] ?? []
  }

  // 加载用户的所有促销码
  @MainActor
  func loadPromotions() async {
    guard !isLoading else { return }
    isLoading = true

    do {
      let response = try await PromotionAPI.shared.getUserPromotions()
      self.promotions = response.items
      isLoading = false
    } catch {
      isLoading = false
      print(error)
    }
  }

  // 创建促销码
  @MainActor
  func createPromotion(productId: String, codes: [String], group: String) async {
    do {
      try await PromotionAPI.shared.createPromotion(
        productId: productId,
        codes: codes,
        group: group
      )
    } catch {
      print(error)
    }
  }

  // 删除促销码
  @MainActor
  func deletePromotion(id: String) async {
    do {
      try await PromotionAPI.shared.deletePromotion(id: id)
    } catch {
      print(error)
    }
  }

}
