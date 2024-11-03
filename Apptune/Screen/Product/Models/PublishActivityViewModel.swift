import Foundation

@MainActor
final class PublishActivityViewModel: ObservableObject {
  // 基本信息
  @Published var activityName: String = ""
  @Published var activityDescription: String = ""

  // 时间设置
  @Published var startTime: Date = Date()
  @Published var endTime: Date = Date().addingTimeInterval(7 * 24 * 3600)  // 默认一周后

  // 状态
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  // 表单验证
  var isValid: Bool {
    !activityName.isEmpty && !activityDescription.isEmpty && startTime < endTime
      && startTime >= Date()
  }

  func publishActivity() async throws {
    guard isValid else {
      errorMessage = "请填写完整的活动信息"
      return
    }

    isLoading = trueå
  }

  // 重置表单
  func reset() {
    activityName = ""
    activityDescription = ""
    startTime = Date()
    endTime = Date().addingTimeInterval(7 * 24 * 3600)
    errorMessage = nil
  }
}
