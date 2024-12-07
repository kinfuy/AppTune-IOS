import Foundation

@MainActor
final class PublishActivityViewModel: ObservableObject {
  @Published var selectedProductId: String?
  // 基本信息
  @Published var activityName: String = ""
  @Published var activityDescription: String = ""
  @Published var cover: String?
  @Published var tags: [TagEntity] = []
  @Published var images:[String] = []

  // 时间设置
  @Published var startTime: Date = Date()
  @Published var endTime: Date = Date().addingTimeInterval(7 * 24 * 3600)

  // 状态
  @Published var isLoading: Bool = false
  @Published var createdActivity: ActiveInfo?

  // 移除 isValid 属性,改用 checkValid 函数
  func checkValid() -> Toast? {
    if selectedProductId == nil || selectedProductId?.isEmpty == true {
      return Toast(msg: "请选择产品")
    }

    if activityName.isEmpty {
      return Toast(msg: "请输入活动标题")
    }

    if activityDescription.isEmpty {
      return Toast(msg: "请输入活动描述")
    }

    if startTime >= endTime {
      return Toast(msg: "结束时间必须晚于开始时间")
    }

    return nil
  }

  func publishActivity() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let params = ActiveCreateParams(
        productId: selectedProductId ?? "",
        title: activityName,
        description: activityDescription,
        cover: cover,
        startTime: startTime,
        endTime: endTime,
        images: images,
        tags: tags.map { TagEntity(name: $0.name, color: $0.color) }
      )

      createdActivity = try await ActiveAPI.shared.createActive(params)
      reset()
    } catch {
        print(error.localizedDescription)
    }
  }

  // 重置表单
  func reset() {
    selectedProductId = nil
    activityName = ""
    activityDescription = ""
    cover = nil
    tags = []
    startTime = Date()
    endTime = Date().addingTimeInterval(7 * 24 * 3600)
    createdActivity = nil
  }

  // 从模板初始化表单
  func initFromTemplate(_ template: ActiveTemplateInfo) {
    activityName = template.title
    activityDescription = template.description ?? ""
    cover = template.cover
    tags = template.tags
    images = template.images
    startTime = template.startTime
    endTime = template.endTime
  }
}
