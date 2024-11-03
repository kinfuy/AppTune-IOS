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
      CoinTask(
        id: "1", title: "每日签到", coin: 10, icon: "checkmark.circle.fill", isCompleted: false,
        type: .daily),
      CoinTask(
        id: "2", title: "浏览文章", coin: 5, icon: "doc.text.fill", isCompleted: false, type: .daily),
      CoinTask(
        id: "3", title: "分享内容", coin: 8, icon: "square.and.arrow.up", isCompleted: false,
        type: .daily),
    ]

    permanentTasks = [
      CoinTask(
        id: "4", title: "完善个人资料", coin: 20, icon: "person.fill", isCompleted: false,
        type: .permanent),
      CoinTask(
        id: "5", title: "绑定手机号", coin: 30, icon: "phone.fill", isCompleted: false, type: .permanent),
      CoinTask(
        id: "6", title: "首次分享", coin: 50, icon: "gift.fill", isCompleted: false, type: .permanent),
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
