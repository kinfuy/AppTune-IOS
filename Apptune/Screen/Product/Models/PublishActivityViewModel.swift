import Foundation

@MainActor
final class PublishActivityViewModel: ObservableObject {
    @Published var selectedProductId: String?
    // 基本信息
    @Published var activityName: String = ""
    @Published var activityDescription: String = ""

    // 时间设置
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date().addingTimeInterval(7 * 24 * 3600) // 默认一周后

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

        isLoading = true
    }

    // 重置表单
    func reset() {
        activityName = ""
        activityDescription = ""
        startTime = Date()
        endTime = Date().addingTimeInterval(7 * 24 * 3600)
        errorMessage = nil
    }

    // 从模板初始化
    func initFromTemplate(_ template: ActivityTemplate) {
        activityName = template.name
        activityDescription = template.description

        // 设置开始和结束时间
        startTime = Date()
        endTime = Calendar.current.date(byAdding: .hour, value: template.duration, to: startTime) ?? Date()
    }
}
