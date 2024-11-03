import Foundation

@MainActor
final class PublishActivityViewModel: ObservableObject {
  @Published var activityName: String = ""
  @Published var activityDescription: String = ""
  @Published var startTime: Date = Date()
  @Published var endTime: Date = Date()

  func publishActivity() async {
    // TODO: 实现活动发布逻辑
  }
}
