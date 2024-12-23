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

  // 加载状态
  @Published var isSelfLoading = false
  @Published var isAllLoading = false
  @Published var isJoinedLoading = false
  @Published var isTopLoading = false
  // 总数统计
  @Published var totalSelfActive: Int = 0
  @Published var totalAllActive: Int = 0
  @Published var totalJoinedActive: Int = 0
  @Published var totalTopActive: Int = 0
  // 使用 actor 来管理页码
  private actor PageManager {
    private var pages: [ActiveType: Int]

    init() {
      pages = [.my: 1, .all: 1, .joined: 1]
    }

    func getCurrentPage(for type: ActiveType) -> Int {
      return pages[type, default: 1]
    }

    func updatePage(for type: ActiveType, refresh: Bool) {
      if refresh {
        pages[type] = 1
      } else {
        pages[type] = pages[type, default: 1] + 1
      }
    }
  }

  private let pageManager = PageManager()
  private let pageSize = 150

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
        isLoading: .init(get: { self.isSelfLoading }, set: { self.isSelfLoading = $0 }),
        total: .init(get: { self.totalSelfActive }, set: { self.totalSelfActive = $0 })
      )
    case .all:
      return (
        actives: .init(get: { self.allActives }, set: { self.allActives = $0 }),
        isLoading: .init(get: { self.isAllLoading }, set: { self.isAllLoading = $0 }),
        total: .init(get: { self.totalAllActive }, set: { self.totalAllActive = $0 })
      )
    case .joined:
      return (
        actives: .init(get: { self.joinedActives }, set: { self.joinedActives = $0 }),
        isLoading: .init(get: { self.isJoinedLoading }, set: { self.isJoinedLoading = $0 }),
        total: .init(get: { self.totalJoinedActive }, set: { self.totalJoinedActive = $0 })
      )
    case .top:
      return (
        actives: .init(get: { self.topActives }, set: { self.topActives = $0 }),
        isLoading: .init(get: { self.isTopLoading }, set: { self.isTopLoading = $0 }),
        total: .init(get: { self.totalTopActive }, set: { self.totalTopActive = $0 })
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

    guard !state.isLoading.wrappedValue else { return }

    // 使用 actor 安全地管理页码
    await pageManager.updatePage(for: type, refresh: refresh)
    let currentPage = await pageManager.getCurrentPage(for: type)

    state.isLoading.wrappedValue = true

    do {
      let response = try await {
        switch type {
        case .my:
          return try await API.getSelfActiveList(
            page: currentPage,
            pageSize: pageSize
          )
        case .all:
          return try await API.getActiveList(
            page: currentPage,
            pageSize: pageSize
          )
        case .joined:
          return try await API.getJoinedActiveList(
            page: currentPage,
            pageSize: pageSize
          )
        case .top:
          return try await API.getTopActiveList(
            page: currentPage,
            pageSize: pageSize
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
  func submitAudit(activeId: String, content: String, images: [String]) async {
    do {
      try await API.submitAudit(activeId: activeId, content: content, images: images)
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
  func getReviewHistory(activeId: String) async -> ActiveSubmission? {
    do {
      let submission = try await API.getReviewHistory(activeId: activeId)
      return submission
    } catch {
      print(error)
      return nil
    }
  }

  func submitAuditResult(activeId: String, status: ReviewStatus, reason: String?) async throws {
    // 实现审核结果提交的API调用
  }
}
