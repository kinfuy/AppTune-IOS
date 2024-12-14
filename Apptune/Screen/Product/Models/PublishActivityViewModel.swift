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

  // 高级配置
  @Published var limit: Int?  // 人数限制
  @Published var reward: RewardType = .selfManaged  // 奖励说明
  @Published var isAutoEnd: Bool = false {
    didSet {
      if isAutoEnd && endAt == nil {
        endAt = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
      }
    }
  }

  // 模板配置
  @Published var isTemplate: Bool = false  // 是否存为模板

  @Published var selectedRewardType: RewardType = .selfManaged
  @Published var pointsAmount: Int = 0

  // 移除 isValid 属性,改用 checkValid 函数
  func checkValid() -> Toast? {
    if product == nil {
      return Toast(msg: "请选择产品")
    }

    if images.isEmpty {
      return Toast(msg: "请上传活动封面")
    }

    if title.isEmpty {
      return Toast(msg: "请输入活动标题")
    }

    if description.isEmpty {
      return Toast(msg: "请输入活动描述")
    }
    return nil
  }

  var activeInfo: ActiveInfo {
    return ActiveInfo(
      id: "",
      title: title,
      description: description,
      cover: (images.first ?? cover) ?? "",
      startAt: startAt,
      endAt: endAt,
      limit: limit,
      rewardType: reward,
      joinCount: nil,
      likeCount: nil,
      status: 0,
      createTime: Date(),
      productId: product!.id,
      productName: product!.name,
      productLogo: product!.icon,
      images: images,
      tags: tags,
      link: nil,
      reward: nil,
      userId: ""
    )
  }

  func publishActivity() async {
    isLoading = true
    defer { isLoading = false }
    do {
      let params = activeInfo
      let _ = try await ActiveAPI.shared.createActive(params, isTemplate)
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
    limit = nil
    reward = .selfManaged
    isAutoEnd = false
  }

  // 从模板初始化表单
  func initFromTemplate(_ template: ActiveTemplateInfo) {
    title = template.title
    description = template.description ?? ""
    cover = template.cover
    tags = template.tags
    images = template.images
    reward = template.rewardType
    limit = template.limit
    isAutoEnd = false
  }
}
