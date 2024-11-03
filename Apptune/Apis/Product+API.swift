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

    let response: AppStoreSearchResponse = try await apiManager.session.data(for: request)
    return response.results
  }

  // func createProduct(product: CreateProductDto) async throws -> Product {
  //   let urlString = "\(BASR_SERVE_URL)/product"

  //   let request = try apiManager.createRequest(
  //     url: urlString,
  //     method: "POST",
  //     body: product.dictionary
  //   )

  //   return try await apiManager.session.data(for: request)
  // }
}

// 创建产品的数据模型
// struct CreateProductDto: Codable {
//   let name: String
//   let description: String
//   let price: Double
//   let stock: Int
//   let isAvailable: Bool
//   let appStoreInfo: AppStoreInfo?

//   var dictionary: [String: Any] {
//     var dict: [String: Any] = [
//       "name": name,
//       "description": description,
//       "price": price,
//       "stock": stock,
//       "isAvailable": isAvailable,
//     ]

//     if let appInfo = appStoreInfo {
//       dict["appStoreInfo"] = [
//         "appId": appInfo.appId,
//         "bundleId": appInfo.bundleId,
//         "appStoreUrl": appInfo.appStoreUrl,
//       ]
//     }

//     return dict
//   }
// }

struct Product: Codable {
  let id: Int
  let name: String
  let description: String
  let price: Double
  let stock: Int
  let isAvailable: Bool
  let createTime: Date
  let updateTime: Date
}
