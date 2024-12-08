//
//  Product+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/3.
//

import Foundation

struct AppSearchInfo: Codable, Identifiable {
  let appId: String
  let name: String
  let description: String
  let developer: String
  let category: String
  let iconUrl: String
  let price: Double
  let rating: Double?
  let ratingCount: Int?
  let appStoreUrl: String
  let bundleId: String
  let version: String?
  let releaseNotes: String?

  // 用于 Identifiable 协议
  var id: String { appId }
}

struct AppStoreSearchResponse: Codable {
  let results: [AppSearchInfo]
}

struct ProductInfo: Codable, Identifiable {
  let id: String
  let name: String
  let description: String
  let icon: String
  let link: String
  let category: Catalog
  let price: Int?
  let createTime: Date
  let status: Int?
  let developer: String?
}

struct ListResponse<T: Codable>: Codable {
  let items: [T]
  let total: Int
  let page: Int
  let pageSize: Int
}

class ProductAPI {
  static let shared = ProductAPI()
  private let apiManager = APIManager.shared

  func searchAppStore(keyword: String) async throws -> [AppSearchInfo] {
    let urlString =
      "\(BASR_SERVE_URL)/product/app-store/search?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    let response: AppStoreSearchResponse = try await apiManager.session.data(
      for: request, loading: false)
    return response.results
  }

  func publishProduct(
    name: String, description: String, icon: String, link: String,
    category: Catalog, appId: String?, developer: String?,
    price: Double?, bundleId: String?, version: String?
  ) async throws {
    let params: [String: Any] = [
      "from": "ios",
      "name": name,
      "description": description,
      "icon": icon,
      "link": link,
      "category": category.rawValue,
      "appId": appId,
      "developer": developer,
      "price": price,
      "bundleId": bundleId,
      "version": version,
    ].compactMapValues { $0 }  // 移除所有 nil 值

    let request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/product",
      method: "POST",
      body: params
    )

    let _ = try await apiManager.session.data(for: request)
  }

  func getSelfProductList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ProductInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/product/myList?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )
    return try await apiManager.session.data(for: request)
  }

  func getAuditProductList() async throws -> ListResponse<
    ProductInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/product/auditList"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )
    return try await apiManager.session.data(for: request)
  }

  /**
     * 审核产品
     * @param id ID
     * @param status 状态
     */
  func auditProduct(id: String, status: Int) async throws {
    let urlString = "\(BASR_SERVE_URL)/product/audit"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "POST",
      body: ["id": id, "status": status]
    )
    let _ = try await apiManager.session.data(for: request)
  }
}
