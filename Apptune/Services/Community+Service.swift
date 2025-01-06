import Foundation

class CommunityService: ObservableObject {
  static let shared = CommunityService()

  @Published var pendingPostReviews: [Post] = []

  @Published var isLoading = false
  @Published var posts: [Post] = []
  @Published var currentPage = 1
  @Published var total = 1
  @Published var hasMore = false
  let pageSize = 10

  @MainActor
  @discardableResult
  func fetchPosts() async -> [Post] {
    do {
      isLoading = true
      let response = try await API.getCommunityPosts(page: currentPage)
      posts = response.items
      currentPage = response.page
      total = response.total
      hasMore = posts.count < total
      isLoading = false
      return posts
    } catch {
      print("🚀 获取帖子失败: \(error)")
      isLoading = false
      return []
    }
  }

  @MainActor
  func createPost(_ post: CreatePostDTO, success: @escaping () -> Void) async {
    do {
      let _ = try await API.createPost(post)
      print("🚀 创建帖子成功")
      success()
    } catch {
      print("🚀 创建帖子失败: \(error)")
    }
  }

  @MainActor
  func deletePost(_ post: Post) async {
    do {
      try await API.deletePost(id: post.id)
      await fetchPosts()
    } catch {
      print("🚀 删除帖子失败: \(error)")
    }
  }

  @MainActor
  func likePost(id: String) async {
    do {
      try await API.likePost(id: id)
      await fetchPosts()
    } catch {
      print("🚀 点赞帖子失败: \(error)")
    }
  }

  @MainActor
  func unlikePost(id: String) async {
    do {
      try await API.unlikePost(id: id)
      await fetchPosts()
    } catch {
      print("🚀 取消点赞帖子失败: \(error)")
    }
  }

  @MainActor
  func loadMorePosts() async {
    if hasMore {
      currentPage += 1
      let newPosts = await fetchPosts()
      posts.append(contentsOf: newPosts)
    }
  }

  @MainActor
  func loadPendingPostReviews() async {
    do {
      let response = try await API.getAuditList()
      pendingPostReviews = response.items
    } catch {
      print("🚀 获取审核帖子列表失败: \(error)")
    }
  }

  @MainActor
  func auditPost(id: String, status: Int) async {
    do {
      try await API.auditPost(id: id, status: status)
      await loadPendingPostReviews()
    } catch {
      print("🚀 审核帖子失败: \(error)")
    }
  }

}

struct CreatePostDTO: Codable {
  let title: String
  let content: String
  let images: [String]
  let link: PostLink?
}
