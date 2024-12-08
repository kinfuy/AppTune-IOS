//
//  Promotion+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import Foundation

struct PromotionCode: Codable {
  let id: String
  let group: String  // 组
  let code: String  // 促销码
  let productId: String?  // 产品ID
  let productName: String?  // 产品名称
  let isUsed: Bool
  let createTime: Date  // 创建时间
}

class PromotionAPI {
  static let shared = PromotionAPI()
  private let apiManager = APIManager.shared

  // 获取用户所有促销码
  func getUserPromotions() async throws -> ListResponse<
    PromotionInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/promotion/list"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )
    return try await apiManager.session.data(for: request)
  }

  // 创建促销码
  func createPromotion(productId: String, codes: [String], group: String)
    async throws
  {
    let params: [String: Any] = [
      "productId": productId,
      "codes": codes,
      "group": group,
    ]

    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/promotion/create",
      method: "POST",
      body: params
    )

    let _ = try await apiManager.session.data(for: request)
  }

  // 删除促销码
  func deletePromotion(id: String) async throws {
    let urlString = "\(BASR_SERVE_URL)/promotion/\(id)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "DELETE",
      body: nil
    )

    let _ = try await apiManager.session.data(for: request)
  }
}
