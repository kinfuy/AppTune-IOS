//
//  Promotion+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import Foundation

// MARK: - Models
struct PromotionCode: Codable {
  let id: String
  let group: String  // 组
  let code: String  // 促销码
  let productId: String  // 产品ID
  let productName: String  // 产品名称
  let productLogo: String  // 产品logo
  let usedUserId: String?  // 使用用户ID
  let usedTime: Date?  // 使用时间
  let createdAt: Date  // 创建时间
  let updatedAt: Date  // 更新时间

  var isUsed: Bool {
    return usedUserId != nil && usedTime != nil
  }
}

// MARK: - API Methods
extension API {
  // 获取用户所有促销码
  static func getUserPromotions() async throws -> ListResponse<PromotionCode> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/promotion/list",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // 创建促销码
  static func createPromotion(productId: String, codes: [String], group: String) async throws {
    let params: [String: Any] = [
      "productId": productId,
      "codes": codes,
      "group": group,
    ]

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/promotion/create",
      method: "POST",
      body: params
    )

    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 删除促销码
  static func deletePromotion(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/promotion/\(id)",
      method: "POST",
      body: nil
    )

    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 检查促销码
  static func checkPromoCodes(_ codes: [String], productId: String) async throws -> [String] {
    let params: [String: Any] = [
      "codes": codes,
      "productId": productId,
    ]

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/promotion/check-codes",
      method: "POST",
      body: params
    )

    return try await API.shared.session.data(for: request)
  }
}
