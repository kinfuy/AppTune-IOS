extension API {
  static func getCommunityPosts(page: Int = 1) async throws -> ListResponse<Post> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts",
      method: "GET",
      body: ["page": page]
    )
    return try await API.shared.session.data(for: request)
  }

  static func createPost(_ post: CreatePostDTO) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/create",
      method: "POST",
      body: post.asDictionary()
    )
    let _ = try await API.shared.session.data(for: request)
  }

  static func likePost(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/helpful",
      method: "POST",
      body: ["id": id]
    )
    let _ = try await API.shared.session.data(for: request)
  }

  static func unlikePost(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/notHelpful",
      method: "POST",
      body: ["id": id]
    )
    let _ = try await API.shared.session.data(for: request)
  }

  static func linkAnalysis(_ url: String) async throws -> PostLink {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/linkAnalysis",
      method: "POST",
      body: ["url": url]
    )
    return try await API.shared.session.data(for: request)
  }

  static func deletePost(id: String) async throws {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/delete",
      method: "POST",
      body: ["id": id]
    )
    let _ = try await API.shared.session.data(for: request)
  }

  // 获取审核帖子列表
  static func getAuditList() async throws -> ListResponse<Post> {
    let request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/community/posts/auditList",
      method: "GET",
      body: nil
    )
    return try await API.shared.session.data(for: request)
  }
}
