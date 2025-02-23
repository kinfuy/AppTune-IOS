import SwiftUI

struct LLMMessage: Codable {
  let model: String
  let messages: [LLMMessage]
  let temperature: Double
  let maxTokens: Int
  let provider: String
}

struct LLMResponse: Codable {
  let role: String
  let content: String
}

// MARK: - API Methods
extension API {
  // chat
  static func chat(messages: [LLMMessage]) async throws -> ListResponse<LLMResponse> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/ai/chat",
      method: "POST",
      body: messages.asDictionary()
    )
    return try await API.shared.session.data(for: request)
  }
}
