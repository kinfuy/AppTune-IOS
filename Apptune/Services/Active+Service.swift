//
//  SwiftUIView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/23.
//

import SwiftUI

enum ActiveType: CaseIterable {
  case my
  case all
  case joined
  case top
}

class ActiveService: ObservableObject {
  static let shared = ActiveService()

  // 活动列表
  @Published var selfActives: [ActiveInfo] = []
  @Published var allActives: [ActiveInfo] = []
  @Published var joinedActives: [ActiveInfo] = []
  @Published var pendingActiveReviews: [ActiveInfo] = []
  @Published var topActives: [ActiveInfo] = []

  @Published var selfPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var allPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var joinedPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var pendingPage = Page(page: 1, pageSize: 150, total: 0, loading: false)
  @Published var topPage = Page(page: 1, pageSize: 150, total: 0, loading: false)

  // 添加数据加载状态追踪
  @Published private var hasLoadedInitialData = false

  // 获取对应类型的状态
  private func getState(for type: ActiveType) -> (
    actives: Binding<[ActiveInfo]>,
    isLoading: Binding<Bool>,
    total: Binding<Int>
  ) {
    switch type {
    case .my:
      return (
        actives: .init(get: { self.selfActives }, set: { self.selfActives = $0 }),
        isLoading: .init(get: { self.selfPage.loading }, set: { self.selfPage.loading = $0 }),
        total: .init(get: { self.selfPage.total }, set: { self.selfPage.total = $0 })
      )
    case .all:
      return (
        actives: .init(get: { self.allActives }, set: { self.allActives = $0 }),
        isLoading: .init(get: { self.allPage.loading }, set: { self.allPage.loading = $0 }),
        total: .init(get: { self.allPage.total }, set: { self.allPage.total = $0 })
      )
    case .joined:
      return (
        actives: .init(get: { self.joinedActives }, set: { self.joinedActives = $0 }),
        isLoading: .init(get: { self.joinedPage.loading }, set: { self.joinedPage.loading = $0 }),
        total: .init(get: { self.joinedPage.total }, set: { self.joinedPage.total = $0 })
      )
    case .top:
      return (
        actives: .init(get: { self.topActives }, set: { self.topActives = $0 }),
        isLoading: .init(get: { self.topPage.loading }, set: { self.topPage.loading = $0 }),
        total: .init(get: { self.topPage.total }, set: { self.topPage.total = $0 })
      )
    }
  }

  // 判断是否还有更多数据
  func hasMore(for type: ActiveType) -> Bool {
    let state = getState(for: type)
    return state.actives.wrappedValue.count < state.total.wrappedValue
  }

  // 统一的加载方法
  @MainActor
  private func loadActives(type: ActiveType, refresh: Bool) async {
    let state = getState(for: type)

    // 只在真正需要显示 loading 时才设置
    let shouldShowLoading = !hasLoadedInitialData || refresh
    if shouldShowLoading {
      state.isLoading.wrappedValue = true
    }

    do {
      let response = try await {
        switch type {
        case .my:
          return try await API.getSelfActiveList(
            page: selfPage.page,
            pageSize: selfPage.pageSize
          )
        case .all:
          return try await API.getActiveList(
            page: allPage.page,
            pageSize: allPage.pageSize
          )
        case .joined:
          return try await API.getJoinedActiveList(
            page: joinedPage.page,
            pageSize: joinedPage.pageSize
          )
        case .top:
          return try await API.getTopActiveList(
            page: topPage.page,
            pageSize: topPage.pageSize
          )
        }
      }()

      // 直接在 MainActor 上更新状态
      if refresh {
        state.actives.wrappedValue = response.items
      } else {
        state.actives.wrappedValue.append(contentsOf: response.items)
      }
      state.total.wrappedValue = response.total
      state.isLoading.wrappedValue = false

      // 设置已加载标志
      hasLoadedInitialData = true
      state.isLoading.wrappedValue = false

    } catch {
      state.isLoading.wrappedValue = false
    }
  }

  // 公开的加载方法也标记为 @MainActor
  @MainActor
  func loadSelfActives(refresh: Bool = false) async {
    await loadActives(type: .my, refresh: refresh)
  }

  @MainActor
  func loadAllActives(refresh: Bool = false) async {
    await loadActives(type: .all, refresh: refresh)
  }

  @MainActor
  func loadJoinedActives(refresh: Bool = false) async {
    await loadActives(type: .joined, refresh: refresh)
  }

  @MainActor
  func loadTopActives(refresh: Bool = false) async {
    await loadActives(type: .top, refresh: refresh)
  }

  @MainActor
  func loadPendingActiveReviews() async {
    do {
      // 获取待审核活动列表,不需要分页
      let response = try await API.getReviewActiveList()
      pendingActiveReviews = response.items
    } catch {
      print(error)
    }
  }

  // 刷新所有数据
  @MainActor
  func refreshAll() async {
    await withTaskGroup(of: Void.self) { group in
      for type in ActiveType.allCases {
        group.addTask {
          await self.loadActives(type: type, refresh: true)
        }
      }
    }
  }

  @MainActor
  func review(id: String, status: Int) async {
    do {
      try await API.auditActive(id: id, status: status)
    } catch {
      print(error)
    }
  }

  // 添加模板列表状态
  @Published var templates: [ActiveTemplateInfo] = []
  @Published var isTemplatesLoading = false

  // 加载模板列表
  @MainActor
  func loadTemplates() async {
    guard !isTemplatesLoading else { return }

    isTemplatesLoading = true

    do {
      templates = try await API.getTemplates()
    } catch {
      print("Failed to load templates:", error)
    }

    isTemplatesLoading = false
  }

  @MainActor
  func deleteActive(id: String, success: @escaping () -> Void) async {
    do {
      try await API.deleteActive(id: id)
      success()
    } catch {
      print(error)
    }
  }

  @MainActor
  func joinActive(id: String, success: @escaping () -> Void) async {
    do {
      try await API.joinActive(id: id)
      success()
    } catch {
      print(error)
    }
  }

  @MainActor
  func submitAudit(
    activeId: String, content: String, images: [String], success: @escaping () -> Void
  ) async {
    do {
      try await API.submitAudit(activeId: activeId, content: content, images: images)
      success()
    } catch {
      print(error)
    }
  }

  func checkActiveStatus(id: String) async -> (hasJoined: Bool, hasSubmitted: Bool) {
    do {
      let response = try await API.checkActiveStatus(id: id)
      return (response.hasJoined, response.hasSubmitted)
    } catch {
      print(error)
      return (false, false)
    }
  }

  @MainActor
  func getReviewHistory(activeId: String, userId: String?) async -> ActiveSubmission? {
    do {
      let submission = try await API.getReviewHistory(activeId: activeId, userId: userId)
      return submission
    } catch {
      print(error)
      return nil
    }
  }

  func submitAuditResult(
    activeId: String, userId: String, status: ReviewStatus, reason: String,
    extra: SubmitExtraParams?,
    success: @escaping () -> Void
  ) async {
    // 实现审核结果提交的API调用
    do {
      try await API.submitAuditResult(
        activeId: activeId, userId: userId, status: status.rawValue, reason: reason, extra: extra)
      success()
    } catch {
      print(error)
    }
  }

  func getActiveRegistrationList(activeId: String) async -> [RegistrationUser]? {
    do {
      let rst = try await API.getActiveRegistrationList(activeId: activeId)
      return rst.items
    } catch {
      print(error)
      return nil
    }
  }

  func getActiveRegistrationStats(activeId: String) async -> RegistrationStats {
    do {
      return try await API.getActiveRegistrationStats(activeId: activeId)
    } catch {
      print(error)
      return RegistrationStats(
        totalJoins: 0, pendingReviews: 0, approvedReviews: 0, rejectedReviews: 0)
    }
  }

  func searchActive(keyword: String) async -> [ActiveInfo] {
    do {
      return try await API.searchActive(keyword: keyword)
    } catch {
      print(error)
      return []
    }
  }

  // 添加一个检查方法
  func needsInitialLoad() -> Bool {
    return !hasLoadedInitialData
  }
}
