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

enum RewardType: String, Codable, CaseIterable {
  case selfManaged = "custom"
  case points = "coin"
  case promoCode = "promocode"
}

struct ActiveInfo: Codable, Identifiable, Hashable {
  let id: String
  let title: String
  let description: String
  let cover: String
  let startAt: Date
  let endAt: Date?  // 结束时间
  let limit: Int?  // 人数限制
  let rewardType: RewardType  // 奖励类型
  let joinCount: Int?
  let likeCount: Int?
  let status: Int
  let createTime: Date
  let productId: String
  let productName: String
  let productLogo: String
  let images: [String]
  let tags: [TagEntity]
  let link: String?
  let reward: String?
  let userId: String

  // 实现 Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)  // 只需要使用 id 作为唯一标识即可
  }

  static func == (lhs: ActiveInfo, rhs: ActiveInfo) -> Bool {
    lhs.id == rhs.id  // 同样只需要比较 id
  }
}

struct ActiveTemplateInfo: Codable, Identifiable {
  let id: String
  let title: String
  let description: String?
  let cover: String?
  let limit: Int?
  let rewardType: RewardType
  let reward: String?
  let link: String?
  let status: Int
  let createTime: Date
  let images: [String]
  let tags: [TagEntity]
}

// 添加创建活动的参数模型
struct CreateActiveParams: Codable {
  let productId: String
  let title: String
  let description: String
  let startTime: Date
  let endTime: Date
  let images: [String]
  let tags: [TagEntity]
  let isAutoEnd: Bool
  // 可选参数
  let cover: String?
  let maxParticipants: Int?
  let reward: String?
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
  func createActive(_ params: ActiveInfo, _ saveTemplate: Bool = false) async throws -> ActiveInfo {
    let urlString = "\(BASR_SERVE_URL)/active/create"

    // 直接转换参数，不需要处理异常
    var body = params.asDictionary()
    if saveTemplate {
      body["saveTemplate"] = true
    }

    let request = try apiManager.createRequest(
      url: urlString,
      method: "POST",
      body: body
    )

    return try await apiManager.session.data(for: request)
  }
}
