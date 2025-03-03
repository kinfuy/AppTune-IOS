import SwiftUI

struct LLMConfig: Codable {
  let model: String
  let messages: [LLMMessage]
  let temperature: Double
  let maxTokens: Int
  let provider: String
}

struct LLMMessage: Codable {
  let role: ChatMessageRole
  let content: String
}

struct LLMResponse: Codable {
  let content: String
}

// MARK: - API Methods
extension API {
  // chat
  static func chat(config: LLMConfig) async throws -> LLMResponse {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/ai/chat",
      method: "POST",
      body: config.asDictionary()
    )

    return try await API.shared.session.data(for: request)
  }

  // 添加新的流式聊天方法
  static func chatStream(
    config: LLMConfig,
    onReceive: @escaping (String) -> Void,
    onError: @escaping (Error) -> Void,
    onComplete: @escaping () -> Void
  ) {
    let urlString = "\(BASR_SERVE_URL)/ai/chat/stream"
    guard let url = URL(string: urlString) else {
      onError(
        NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的URL: \(urlString)"])
      )
      return
    }

    func getToken() -> String? {
      let token = UserService.shared.auth.accessToken
      return token.isEmpty ? nil : token
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
    request.timeoutInterval = 30  // 设置30秒超时

    if let token = getToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    // 打印请求配置
    do {
      let jsonData = try JSONSerialization.data(
        withJSONObject: config.asDictionary(), options: .prettyPrinted)
      request.httpBody = jsonData
    } catch {
      onError(error)
      return
    }

    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        DispatchQueue.main.async {
          onError(error)
        }
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        DispatchQueue.main.async {
          onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "响应类型无效"]))
        }
        return
      }

      if !(200...201).contains(httpResponse.statusCode) {
        let errorMessage = "HTTP错误: \(httpResponse.statusCode)"
        DispatchQueue.main.async {
          onError(
            NSError(
              domain: "",
              code: httpResponse.statusCode,
              userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
        }
        return
      }

      if let data = data,
        let text = String(data: data, encoding: .utf8)
      {
        // 移除日志以减少噪音
        text.components(separatedBy: "\n\n").forEach { chunk in
          guard !chunk.isEmpty else { return }

          if chunk.hasPrefix("data: ") {
            let content = chunk.dropFirst(6)

            // 处理特殊情况：[DONE] 标记
            if content.trimmingCharacters(in: .whitespaces) == "[DONE]" {
              return
            }

            do {
              if let data = content.data(using: .utf8) {
                // 尝试解析 JSON
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["content"] as? String
                {
                  DispatchQueue.main.async {
                    onReceive(message)
                  }
                } else {
                  // 如果 JSON 解析失败，直接使用原始内容
                  let plainContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                  if !plainContent.isEmpty {
                    DispatchQueue.main.async {
                      onReceive(plainContent)
                    }
                  }
                }
              }
            } catch {
              print("⚠️ 解析警告: \(error)")
            }
          }
        }
      } else {
        print("⚠️ 无法将响应数据转换为文本")
      }

      DispatchQueue.main.async {
        print("✅ 请求完成")
        onComplete()
      }
    }

    task.resume()
    print("🚀 请求已发送")
  }
}
