//
//  Active+API.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/23.
//

import SwiftUI

// MARK: - API Methods
extension API {
  // 获取审核活动列表
  static func getReviewActiveList() async throws -> ListResponse<ActiveInfo> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/auditList",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取个人活动列表
  static func getSelfActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ActiveInfo
  > {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/myList",
      method: "GET",
      body: ["page": page, "pageSize": pageSize]
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取参与的活动列表
  static func getJoinedActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ActiveInfo
  > {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/joinList",
      method: "GET",
      body: ["page": page, "pageSize": pageSize]
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取活动列表
  static func getActiveList(page: Int = 1, pageSize: Int = 10) async throws -> ListResponse<
    ActiveInfo
  > {
    let urlString = "\(BASR_SERVE_URL)/active/list?page=\(page)&pageSize=\(pageSize)"
    let request = try API.shared.createRequest(
      url: urlString,
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取置顶活动列表
  static func getTopActiveList(page: Int = 1, pageSize: Int = 5) async throws -> ListResponse<
    ActiveInfo
  > {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/tops",
      method: "GET",
      body: ["page": page, "pageSize": pageSize]
    )
    return try await API.shared.session.data(for: request)
  }

  // 审核活动
  static func auditActive(id: String, status: Int) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/audit",
      method: "POST",
      body: ["id": id, "status": status]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 获取个人模板列表
  static func getMyActiveTemplateList(page: Int = 1, pageSize: Int = 10) async throws
    -> ListResponse<ActiveTemplateInfo>
  {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active-template/myList",
      method: "GET",
      body: ["page": page, "pageSize": pageSize]
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取用户模板列表
  static func getTemplates() async throws -> [ActiveTemplateInfo] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active-template/templates",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // 创建活动
  static func createActive(_ params: ActiveInfo, _ saveTemplate: Bool = false) async throws {
    var body = params.asDictionary()
    if saveTemplate {
      body["saveTemplate"] = true
    }

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/create",
      method: "POST",
      body: body
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 更新活动
  static func updateActive(_ params: ActiveInfo) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/update",
      method: "POST",
      body: params.asDictionary()
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 删除活动
  static func deleteActive(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/delete",
      method: "POST",
      body: ["id": id]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 报名活动
  static func joinActive(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/join",
      method: "POST",
      body: ["activeId": id]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 提交审核
  static func submitAudit(activeId: String, content: String, images: [String]) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/submission/create",
      method: "POST",
      body: ["activeId": activeId, "content": content, "images": images]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 查询活动状态
  static func checkActiveStatus(id: String) async throws -> ActiveStatus {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/submission/check",
      method: "GET",
      body: ["activeId": id]
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取审核历史
  static func getReviewHistory(activeId: String, userId: String?) async throws -> ActiveSubmission {
    var body = ["activeId": activeId]
    if let userId = userId {
      body["userId"] = userId
    }
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/submission/history",
      method: "GET",
      body: body
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取活动报名用户列表
  static func getActiveRegistrationList(activeId: String) async throws -> ListResponse<
    RegistrationUser
  > {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/registration/list",
      method: "GET",
      body: ["activeId": activeId]
    )
    return try await API.shared.session.data(for: request)
  }

  // 获取活动报名用户统计
  static func getActiveRegistrationStats(activeId: String) async throws -> RegistrationStats {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/registration/stats",
      method: "GET",
      body: ["activeId": activeId]
    )
    return try await API.shared.session.data(for: request)
  }

  // 提交审核结果
  static func submitAuditResult(
    activeId: String, userId: String, status: Int, reason: String?, extra: SubmitExtraParams? = nil
  ) async throws {
    var body =
      ["activeId": activeId, "userId": userId, "status": status, "reason": reason ?? ""]
      as [String: Any]
    if let extra = extra {
      body["group"] = extra.group
      body["coin"] = extra.coin
    }
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/submission/submit",
      method: "POST",
      body: body
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  // 搜索活动
  static func searchActive(keyword: String) async throws -> [ActiveInfo] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/active/search",
      method: "GET",
      body: ["keyword": keyword]
    )
    return try await API.shared.session.data(for: request)
  }

  // 审核帖子
  static func auditPost(id: String, status: Int) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/audit",
      method: "POST",
      body: ["id": id, "status": status]
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }
}
