import Foundation

class SelectChatViewModel: ObservableObject {
  // 发布的属性，用于UI更新
  @Published var groups: [AgentGroup] = []
  @Published var agents: [Agent] = []
  @Published var selectedGroup: AgentGroup? = nil
  @Published var searchText: String = ""
  @Published var isLoading = false

  var filteredGroups: [AgentGroup] {
    if searchText.isEmpty {
      return groups
    }
    return groups.filter { group in
      group.agents.contains { agent in
        agent.name.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  // 加载数据
  @MainActor
  func loadData() async {
    isLoading = true
    do {
      let fetchedGroups = try await API.getAgentGroupList()
      self.groups = fetchedGroups
    } catch {
      print("加载群组失败: \(error)")

    }

    do {
      let fetchedAgents = try await API.getAgentList()
      print("获取到代理数据: \(fetchedAgents)")
      self.agents = fetchedAgents
    } catch {
      print("加载代理失败: \(error)")

    }

    isLoading = false
  }

  // 选择组
  func selectGroup(_ group: AgentGroup) {
    print("选择群组: \(group.name)")
    if selectedGroup?.id == group.id {
      selectedGroup = nil
      // 重置为所有agents
      Task { @MainActor in
        await loadAgentsForGroup(nil)
      }
    } else {
      selectedGroup = group
      // 加载该组的agents
      Task { @MainActor in
        await loadAgentsForGroup(group.id)
      }
    }
  }

  // 根据组ID加载agents
  @MainActor
  func loadAgentsForGroup(_ groupId: String?) async {
    isLoading = true

    do {
      let groupAgents = try await API.getAgentList(groupId: groupId)
      self.agents = groupAgents
    } catch {
      print("加载群组代理失败: \(error)")
    }

    isLoading = false
  }

  // 初始化时加载数据
  init() {
    Task { @MainActor in
      await loadData()
    }
  }
}
