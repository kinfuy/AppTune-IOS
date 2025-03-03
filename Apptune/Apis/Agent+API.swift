import Foundation

// MARK: - Models
struct AgentConfiguration: Codable {
  let temperature: Double
  let maxTokens: Int
  let topP: Double
}

struct AgentPrompt: Codable {
  let systemPrompt: String
  let userPrompt: String
}

struct Agent: Codable, Identifiable, Equatable, Hashable {
  static func == (lhs: Agent, rhs: Agent) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description
      && lhs.avatar == rhs.avatar && lhs.isPublic == rhs.isPublic
      && lhs.status == rhs.status && lhs.isModerator == rhs.isModerator
      && lhs.isCustom == rhs.isCustom
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  let id: String
  let userId: String
  let name: String
  let description: String
  let avatar: String
  let isPublic: Bool
  let status: Int
  let isModerator: Bool
  let isCustom: Bool
  let configuration: AgentConfiguration
  let prompts: AgentPrompt
  let type: String
  let createTime: Date
  let updateTime: Date
}

struct AgentGroup: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String
  let description: String
  let status: Int
  let createTime: Date
  let updateTime: Date
  let agents: [Agent]
}

// MARK: - API Methods
extension API {
  // Agent CRUD
  static func createAgent(_ params: [String: Any]) async throws -> Agent {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/create",
      method: "POST",
      body: params
    )
    return try await API.shared.session.data(for: request)
  }

  static func updateAgent(_ params: [String: Any]) async throws -> Agent {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/update",
      method: "POST",
      body: params
    )
    return try await API.shared.session.data(for: request)
  }

  static func deleteAgent(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/\(id)",
      method: "DELETE",
      body: nil
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  static func getAgentList(groupId: String? = nil) async throws -> [Agent] {
    var params: [String: Any] = [:]
    if let groupId = groupId {
      params["groupId"] = groupId
    }

    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/list",
      method: "GET",
      body: params
    )
    return try await API.shared.session.data(for: request)
  }

  static func getAgent(id: String) async throws -> Agent {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/\(id)",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }

  // Agent Group CRUD
  static func createAgentGroup(_ params: [String: Any]) async throws -> AgentGroup {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/group/create",
      method: "POST",
      body: params
    )
    return try await API.shared.session.data(for: request)
  }

  static func updateAgentGroup(_ params: [String: Any]) async throws -> AgentGroup {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/group/update",
      method: "POST",
      body: params
    )
    return try await API.shared.session.data(for: request)
  }

  static func deleteAgentGroup(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/group/\(id)",
      method: "DELETE",
      body: nil
    )
    let _: VoidCodable = try await API.shared.session.data(for: request)
  }

  static func getAgentGroupList() async throws -> [AgentGroup] {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/agent/group/list",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }
}
