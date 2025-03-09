// MARK: - Models
import SwiftUI

struct TagEntity: Codable {
  let name: String
  let color: Color
}

enum RewardType: String, Codable, CaseIterable {
  case selfManaged = "custom"
  case points = "coin"
  case promoCode = "promocode"
}

enum AuditType: Int, Codable, CaseIterable {
  case manual = 1  // 人工审核
  case noAudit = 2  // 无需审核

  var title: String {
    switch self {
    case .manual: return "人工审核"
    case .noAudit: return "无需审核"
    }
  }

  var description: String {
    switch self {
    case .manual: return "需要人工审核，需要报名后需要提交审核附件"
    case .noAudit: return "无需审核，用户报名即可获得奖励"
    }
  }
}

struct ActiveInfo: Codable, Identifiable, Hashable {
  let id: String
  let title: String
  let description: String
  let cover: String
  let startAt: Date
  let endAt: Date?  // 结束时间
  let isAutoEnd: Bool
  let limit: Int?  // 人数限制
  let rewardType: RewardType  // 奖励类型
  let joinCount: Int?
  let likeCount: Int?
  let status: Int
  let createTime: Date
  let productId: String
  let productName: String
  let productLogo: String
  let images: [String]
  let tags: [TagEntity]
  let link: String?
  let reward: String?  // 奖励说明
  let auditType: AuditType  // 审核类型
  let isAutoReward: Bool?  // 是否自动发放奖励
  let rewardPoints: Int?  // 奖励积分
  let rewardPromoCodes: [String]?  // 奖励优惠码
  let userId: String
  let isTop: Bool?
  let recommendTag: String?
  let recommendDesc: String?
  let pubMode: PublishMode  // 发布模式

  // 实现 Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ActiveInfo, rhs: ActiveInfo) -> Bool {
    lhs.id == rhs.id
  }
}

struct ActiveTemplateInfo: Codable, Identifiable {
  let id: String
  let title: String
  let description: String?
  let cover: String?
  let limit: Int?
  let rewardType: RewardType
  let reward: String?
  let link: String?
  let status: Int
  let createTime: Date
  let images: [String]
  let tags: [TagEntity]
  let pubMode: PublishMode?
}

struct ActiveStatus: Codable {
  let hasJoined: Bool
  let hasSubmitted: Bool
}

struct RegistrationStats: Codable {
  let totalJoins: Int
  let pendingReviews: Int
  let approvedReviews: Int
  let rejectedReviews: Int
}

struct SubmitExtraParams: Codable {
  let userId: String?
  let group: String?
  let coin: Int?
  init(userId: String? = nil, group: String? = nil, coin: Int? = nil) {
    self.group = group
    self.coin = coin
    self.userId = userId
  }
}

// 添加 ActiveSubmission 模型
struct ActiveSubmission: Codable {
  let id: String
  let userId: String
  let activeId: String
  let content: String
  let images: [String]?
  let status: Int
  let reviewHistory: [ReviewRecord]
  let createTime: Date
}
