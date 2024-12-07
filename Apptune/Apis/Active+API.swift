//
//  Active+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/23.
//

import SwiftUI

struct TagEntity: Codable {
  let name: String
  let color: Color
}

struct ActiveInfo: Codable, Identifiable {
  let id: String
  let title: String
  let description: String
  let cover: String
  let startAt: Date
  let endAt: Date
  let joinCount: Int
  let likeCount: Int
  let status: Int
  let createTime: Date
  let productId: String
  let productName: String
  let productLogo: String
  let images:[String]
  let tags: [TagEntity]
}

struct ActiveTemplateInfo: Codable, Identifiable {
  let id: String
  let title: String
  let description: String?
  let cover: String?
  let startTime: Date
  let endTime: Date
  let status: Int
  let createTime: Date
  let images:[String]
  let tags: [TagEntity]
}

// 活动创建参数结构体
struct ActiveCreateParams: Codable {
  let productId: String
  let title: String
  let description: String
  let cover: String?
  let startTime: Date
  let endTime: Date
  let images:[String]
  let tags: [TagEntity]
}

class ActiveAPI {
  static let shared = ActiveAPI()
  private let apiManager = APIManager.shared

  func getReviewActiveList() async throws -> ListResponse<
    ActiveInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/active/auditList"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  func getSelfActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<ActiveInfo>
  {
    let urlString = "\(BASR_SERVE_URL)/active/myList?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  func getJoinedActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ActiveInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/active/joinList?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  func getActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<ActiveInfo> {
    let urlString = "\(BASR_SERVE_URL)/active/list?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  /**
   * 审核活动
   * @param id 活动ID
   * @param status 状态
   */
  func auditActive(id: String, status: Int) async throws {
    let urlString = "\(BASR_SERVE_URL)/active/audit"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "POST",
      body: ["id": id, "status": status]
    )
    let _ = try await apiManager.session.data(for: request)
  }

  // 添加获取我的模板列表的方法
  func getMyActiveTemplateList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ActiveTemplateInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/active-template/myList?page=\(page)&pageSize=\(pageSize)"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  // 获取用户模板列表(不分页)
  func getTemplates() async throws -> [ActiveTemplateInfo] {
    let urlString = "\(BASR_SERVE_URL)/active-template/templates"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )

    return try await apiManager.session.data(for: request)
  }

  // 添加创建活动的方法
  func createActive(_ params: ActiveCreateParams) async throws -> ActiveInfo {
    let urlString = "\(BASR_SERVE_URL)/active/create"

    // 将参数转换为字典形式
    var body: [String: Any] = [
      "productId": params.productId,
      "title": params.title,
      "description": params.description,
      "startTime": params.startTime,
      "endTime": params.endTime,
    ]

    // 如果有封面图,添加到参数中
    if let cover = params.cover {
      body["cover"] = cover
    }

    let request = try apiManager.createRequest(
      url: urlString,
      method: "POST",
      body: body  // 使用字典形式传参
    )

    return try await apiManager.session.data(for: request)
  }
}
