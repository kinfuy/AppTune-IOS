import Foundation

class SearchHistory {
  private let maxHistoryItems = 10
  private let storageKey = "search_history"

  func getSearchHistory() -> [String] {
    return UserDefaults.standard.stringArray(forKey: storageKey) ?? []
  }

  func addSearchHistory(_ keyword: String) {
    var history = getSearchHistory()

    // 删除已存在的相同关键词
    history.removeAll { $0 == keyword }

    // 添加到开头
    history.insert(keyword, at: 0)

    // 保持最大数量
    if history.count > maxHistoryItems {
      history = Array(history.prefix(maxHistoryItems))
    }

    UserDefaults.standard.set(history, forKey: storageKey)
  }

  func clearHistory() {
    UserDefaults.standard.removeObject(forKey: storageKey)
  }
}
