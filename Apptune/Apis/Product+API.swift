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
  let id: Int
  let name: String
  let description: String
  let icon: String
  let link: String
  let category: String
  let price: Int?
  let createTime: Date
  let developer: String?
}

struct EventInfo:Codable, Identifiable {
    let id:Int;
    let name:String;
    let description:String;
    let cover:String;
    let smallCover:String;
    let startAt:Date;
    let endAt:Data;
    let joined:Int
    let status: String
    
}

struct ProductListResponse: Codable {
  let items: [ProductInfo]
  let total: Int
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
    category: String, appId: String?, developer: String?,
    price: Double?, bundleId: String?, version: String?
  ) async throws {
    let params: [String: Any] = [
      "from": "ios",
      "name": name,
      "description": description,
      "icon": icon,
      "link": link,
      "category": category,
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

  func getProductList(page: Int = 1, pageSize: Int = 10) async throws -> ProductListResponse {
    let urlString = "\(BASR_SERVE_URL)/product/my?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  func getFollowedProducts(page: Int = 1, pageSize: Int = 10) async throws -> ProductListResponse {
    let urlString = "\(BASR_SERVE_URL)/product/followed?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }
}
