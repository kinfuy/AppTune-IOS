import Foundation

struct ProductBasicInfo {
  let id: String
  let name: String
  let icon: String
}

@MainActor
final class PublishActivityViewModel: ObservableObject {
  @Published var isEditMode: Bool = false
  @Published var editingActivityId: String?

  @Published var product: ProductBasicInfo?
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

  @Published var rewardType: RewardType = .selfManaged  // 奖励类型
  @Published var rewardDesc: String = ""  // 奖励说明
  @Published var isAudit: Bool = true  // 是否需要审核
  @Published var isAutoReward: Bool = false  // 是否自动发放奖励
  @Published var points: Int = 0
  @Published var promoGroups: [String] = []

  // 添加步骤状态
  @Published var step: PublishStep = .selectProduct
  // 添加模式状态
  @Published var publishMode: PublishMode = .quick

  @Published var isAutoEnd: Bool = false {
    didSet {
      if isAutoEnd && endAt == nil {
        endAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
      }
    }
  }

  // 模板配置
  @Published var isTemplate: Bool = false  // 是否存为模板

  @Published var selectedRewardType: RewardType = .selfManaged
  @Published var pointsAmount: Int = 0

  // 添加原始数据属性
  private var originalActive: ActiveInfo?

  // 移除 isValid 属性,改用 checkValid 函数
  func checkValid() -> Toast? {
    if !isEditMode && product == nil {
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

    if rewardType == .promoCode && promoGroups.isEmpty {
      return Toast(msg: "请选择促销码")
    }

    if rewardType == .points && points == 0 {
      return Toast(msg: "请设置积分奖励")
    }

    return nil
  }

  var activeInfo: ActiveInfo {
    return ActiveInfo(
      id: editingActivityId ?? "",
      title: title,
      description: description,
      cover: (images.first ?? cover) ?? "",
      startAt: startAt,
      endAt: endAt,
      isAutoEnd: isAutoEnd,
      limit: limit,
      rewardType: rewardType,
      joinCount: nil,
      likeCount: nil,
      status: 0,
      createTime: Date(),
      productId: product?.id ?? "",
      productName: product?.name ?? "",
      productLogo: product?.icon ?? "",
      images: images,
      tags: tags,
      link: nil,
      reward: rewardDesc,
      auditType: isAudit ? .manual : .noAudit,
      isAutoReward: isAutoReward,
      rewardPoints: points,
      rewardPromoCodes: promoGroups,
      userId: "",
      isTop: false,
      recommendTag: nil,
      recommendDesc: nil,
      pubMode: publishMode
    )
  }

  func publishOrUpdateActivity(success: @escaping () -> Void) async {
    isLoading = true
    defer { isLoading = false }

    do {
      let params = activeInfo
      if isEditMode {
        let _ = try await API.updateActive(params)
      } else {
        let _ = try await API.createActive(params, isTemplate)
      }
      reset()
      success()
    } catch {
      print(error.localizedDescription)
    }
  }

  // 重置表单
  func reset() {
    originalActive = nil
    isEditMode = false
    editingActivityId = nil
    product = nil
    title = ""
    description = ""
    cover = nil
    tags = []
    images = []
    startAt = Date()
    endAt = nil
    isAutoEnd = false
    limit = nil
    rewardType = .selfManaged
    rewardDesc = ""
    points = 0
    promoGroups = []
    isAutoEnd = false
  }

  // 从模板初始化表单
  func initFromTemplate(_ template: ActiveTemplateInfo) {
    title = template.title
    description = template.description ?? ""
    cover = template.cover
    tags = template.tags
    images = template.images
    rewardType = template.rewardType
    rewardDesc = template.reward ?? ""
    limit = template.limit
    isAutoEnd = false
    if let pubMode = template.pubMode {
      publishMode = pubMode
    } else {
      var pubMode: PublishMode = .quick
      if template.rewardType == .promoCode || template.rewardType == .points
        || template.limit != nil || template.reward != nil
      {
        pubMode = .pro
      }
      publishMode = pubMode
    }
  }

  func editActivity(active: ActiveInfo) {
    isEditMode = true
    editingActivityId = active.id
    // 保存原始数据
    originalActive = active

    // 如果有产品信息,设置基本产品信息
    if active.productId != "" {
      product = ProductBasicInfo(
        id: active.productId,
        name: active.productName,
        icon: active.productLogo
      )
      step = .editActivity
    }

    title = active.title
    description = active.description
    cover = active.cover
    tags = active.tags
    images = active.images
    startAt = active.startAt
    endAt = active.endAt
    isAutoEnd = active.isAutoEnd
    limit = active.limit
    publishMode = active.pubMode
    rewardType = active.rewardType
    isAudit = active.auditType == .manual
    isAutoReward = active.isAutoReward ?? false
    rewardDesc = active.reward ?? ""
    points = active.rewardPoints ?? 0
    promoGroups = active.rewardPromoCodes ?? []
  }

  func hasUnsavedChanges() -> Bool {
    // 如果是编辑模式,对比原始数据和当前数据
    if let originalActive = originalActive {
      return title != originalActive.title || description != originalActive.description
        || images != originalActive.images || rewardDesc != (originalActive.reward ?? "")
        || limit != originalActive.limit || startAt != originalActive.startAt
        || endAt != originalActive.endAt || publishMode != originalActive.pubMode
    }

    // 如果是新建模式,检查是否填写了内容
    return !title.isEmpty || !description.isEmpty || !images.isEmpty || !rewardDesc.isEmpty
      || limit != nil || isAutoEnd
  }

  /// 从专业模式切换到快速模式时重置相关表单
  func switchToQuickMode(_ mode: PublishMode) {
    if mode == .quick {
      // 重置奖励相关设置
      rewardType = .selfManaged
      rewardDesc = ""
      points = 0
      promoGroups = []

      // 重置高级配置
      limit = nil
      isAutoEnd = false
      endAt = nil
    }

    // 设置发布模式为快速模式
    publishMode = mode
  }
}
