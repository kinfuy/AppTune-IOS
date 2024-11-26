//
//  Active+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/23.
//

import SwiftUI

struct ActiveInfo: Codable, Identifiable {
  let id: String
  let title: String
  let description: String
  let cover: String
  let smallCover: String
  let startAt: Date
  let endAt: Date
  let joinCount: Int
  let likeCount: Int
  let status: Int
  let createTime: Date
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
  func auditActive(id: String, status: Int) async throws  {
    let urlString = "\(BASR_SERVE_URL)/active/audit"

    let request = try apiManager.createRequest(
      url: urlString,
      method: "POST",
      body: ["id": id, "status": status]
    )
    let _ = try await apiManager.session.data(for: request)
  }
}
