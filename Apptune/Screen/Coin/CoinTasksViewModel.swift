import Foundation

struct CoinTask: Identifiable {
  let id: String
  let title: String
  let coin: Int
  let icon: String
  var isCompleted: Bool
  let type: TaskType

  enum TaskType {
    case daily
    case permanent
  }
}

@MainActor
class CoinTasksViewModel: ObservableObject {
  @Published var dailyTasks: [CoinTask] = []
  @Published var permanentTasks: [CoinTask] = []
  @Published var showCompletionAlert = false
  @Published var completedTaskCoin = 0

  init() {
    Task {
      await fetchTasks()
    }
  }

  func fetchTasks() async {
    // TODO: 从服务器获取任务列表
    // 示例数据
    dailyTasks = [
        
    ]

    permanentTasks = [

    ]
  }

  func completeTask(_ task: CoinTask) {
    // TODO: 调用服务器完成任务接口
    completedTaskCoin = task.coin
    showCompletionAlert = true

    // 更新任务状态
    if task.type == .daily {
      if let index = dailyTasks.firstIndex(where: { $0.id == task.id }) {
        dailyTasks[index].isCompleted = true
      }
    } else {
      if let index = permanentTasks.firstIndex(where: { $0.id == task.id }) {
        permanentTasks[index].isCompleted = true
      }
    }
  }
}
