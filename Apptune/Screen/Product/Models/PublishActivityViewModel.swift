import Foundation

@MainActor
final class PublishActivityViewModel: ObservableObject {
  @Published var product: ProductInfo?
  // 基本信息
  @Published var title: String = ""
  @Published var description: String = ""
  @Published var cover: String?
  @Published var tags: [TagEntity] = []
  @Published var images: [String] = []

  // 时间设置
  @Published var startAt: Date = Date()
  @Published var endAt: Date?

  // 状态
  @Published var isLoading: Bool = false
  @Published var createdActivity: ActiveInfo?

  // 高级配置
  @Published var limit: Int?  // 人数限制
    @Published var reward: RewardType = .custom  // 奖励说明
  @Published var isAutoEnd: Bool = true  // 是否自动结束

  // 移除 isValid 属性,改用 checkValid 函数
  func checkValid() -> Toast? {
      if product == nil {
      return Toast(msg: "请选择产品")
    }

    if title.isEmpty {
      return Toast(msg: "请输入活动标题")
    }

    if description.isEmpty {
      return Toast(msg: "请输入活动描述")
    }

    if startAt >= endAt ?? startAt {
      return Toast(msg: "结束时间必须晚于开始时间")
    }

    if let max = limit, max <= 0 {
      return Toast(msg: "参与人数限制必须大于0")
    }

    return nil
  }

  func publishActivity() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let params = ActiveInfo(
        id: "",
        title: title,
        description: description,
        cover: cover ?? "",
        startAt: startAt,
        endAt: endAt,
        limit: limit,
        rewardType: reward,
        joinCount: nil,
        likeCount: nil,
        status: 0,
        createTime: Date(),
        productId: product!.id,
        productName: "",
        productLogo: "",
        images: images,
        tags: tags
      )

      createdActivity = try await ActiveAPI.shared.createActive(params)
      reset()
    } catch {
      print(error.localizedDescription)
    }
  }

  // 重置表单
  func reset() {
    product = nil
    title = ""
    description = ""
    cover = nil
    tags = []
    startAt = Date()
    endAt = nil
    createdActivity = nil
    limit = nil
    reward = .custom
    isAutoEnd = true
  }

  // 从模板初始化表单
  func initFromTemplate(_ template: ActiveTemplateInfo) {
    title = template.title
    description = template.description ?? ""
    cover = template.cover
    tags = template.tags
    images = template.images
    isAutoEnd = true
    startAt = template.startTime
    endAt = template.endTime
  }
}
