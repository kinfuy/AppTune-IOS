import SwiftUI

enum ProductRole: String, CaseIterable, Identifiable, Hashable {
  // 特殊角色
  case user = "我"

  // 系统内置角色
  case productManager = "产品经理"
  case designer = "设计师"
  case developer = "开发工程师"
  case marketingManager = "市场经理"
  case projectManager = "项目经理"
  case architect = "架构师"

  // 新增产品开发相关角色
  case qaEngineer = "测试工程师"
  case dataAnalyst = "数据分析师"
  case userResearcher = "用户研究员"
  case contentManager = "内容运营"
  case businessAnalyst = "商业分析师"
  case devOpsEngineer = "运维工程师"
  case securityExpert = "安全专家"

  var id: String { rawValue }

  // 判断是否为系统内置角色
  var isSystemRole: Bool {
    switch self {
    case .user: return true
    case .productManager, .designer, .developer,
      .marketingManager, .projectManager, .architect:
      return true
    default:
        return false
    }
  }

  // 是否在角色选择界面可见
  var isSelectable: Bool {
    switch self {
    case .user: return false
    default: return true
    }
  }

  var icon: String {
    switch self {
    case .user: return "person.circle.fill"
    case .productManager: return "person.text.rectangle.fill"
    case .designer: return "paintpalette.fill"
    case .developer: return "hammer.fill"
    case .marketingManager: return "chart.line.uptrend.xyaxis.circle.fill"
    case .projectManager: return "clock.fill"
    case .architect: return "building.2.fill"
    case .qaEngineer: return "checklist"
    case .dataAnalyst: return "chart.bar.fill"
    case .userResearcher: return "person.2.circle.fill"
    case .contentManager: return "doc.text.fill"
    case .businessAnalyst: return "briefcase.fill"
    case .devOpsEngineer: return "server.rack"
    case .securityExpert: return "lock.shield.fill"
    }
  }

  var description: String {
    switch self {
    case .user:
      return "用户"
    case .productManager:
      return "专注于产品策略和用户需求分析"
    case .designer:
      return "关注用户体验和界面设计"
    case .developer:
      return "专注技术实现和架构设计"
    case .marketingManager:
      return "负责市场策略和竞品分析"
    case .projectManager:
      return "负责项目进度和资源协调"
    case .architect:
      return "负责系统架构和技术选型"
    case .qaEngineer:
      return "负责产品质量保证和测试流程"
    case .dataAnalyst:
      return "负责数据分析和用户行为研究"
    case .userResearcher:
      return "专注用户研究和需求挖掘"
    case .contentManager:
      return "负责产品内容策略和运营"
    case .businessAnalyst:
      return "负责商业模式分析和市场机会"
    case .devOpsEngineer:
      return "负责系统部署和运维保障"
    case .securityExpert:
      return "负责产品安全和风险控制"
    }
  }

  var backgroundColor: Color {
    switch self {
    case .user: return .gray
    case .productManager: return .blue
    case .designer: return .purple
    case .developer: return .green
    case .marketingManager: return .orange
    case .projectManager: return .indigo
    case .architect: return .mint
    case .qaEngineer: return .red
    case .dataAnalyst: return .cyan
    case .userResearcher: return .pink
    case .contentManager: return .brown
    case .businessAnalyst: return .teal
    case .devOpsEngineer: return .yellow
    case .securityExpert: return .gray
    }
  }

  // 获取所有可选择的角色
  static var selectableRoles: [ProductRole] {
    Self.allCases.filter { $0.isSelectable }
  }
}

// 添加自定义角色结构体
struct CustomRole: Identifiable, Hashable {
  let id = UUID()
  var name: String
  var icon: String
  var description: String
  var backgroundColor: Color

  // 转换为 ProductRole
  var asProductRole: ProductRole {
    // 由于 ProductRole 是枚举，这里需要扩展它以支持自定义角色
    // 暂时返回 .user 作为占位符
    .user
  }
}

struct RecommendedGroup: Hashable {
  let name: String
  let roles: [ProductRole]
}

extension ProductRole {
  static let recommendedGroups: [RecommendedGroup] = [
    RecommendedGroup(
      name: "产品规划小组",
      roles: [.productManager, .projectManager, .designer]
    ),
    RecommendedGroup(
      name: "创意风暴团队",
      roles: [.productManager, .designer, .developer]
    ),
    RecommendedGroup(
      name: "技术评估组",
      roles: [.projectManager, .developer, .architect]
    ),
    RecommendedGroup(
      name: "质量保障团队",
      roles: [.qaEngineer, .developer, .devOpsEngineer]
    ),
    RecommendedGroup(
      name: "用户研究小组",
      roles: [.userResearcher, .dataAnalyst, .productManager]
    ),
    RecommendedGroup(
      name: "安全评估团队",
      roles: [.securityExpert, .architect, .devOpsEngineer]
    ),
    RecommendedGroup(
      name: "运营分析组",
      roles: [.contentManager, .businessAnalyst, .marketingManager]
    ),
  ]
}

// 角色能力和专长定义
struct RoleCapability: Hashable {
  let name: String
  let description: String
  let level: Int  // 1-5 表示熟练度
}

// 角色的系统配置
struct RoleConfiguration: Hashable {
  let temperature: Double  // AI 响应的创造性程度 (0.0-1.0)
  let maxTokens: Int  // 单次响应的最大长度
  let topP: Double  // 采样的概率阈值 (0.0-1.0)
}

// 角色提示词模板
struct RolePrompt: Hashable {
  let systemPrompt: String  // 系统角色设定
  let contextPrompt: String  // 上下文提示
  let examplePrompts: [String]  // 示例对话
}

extension ProductRole {
  // 角色能力配置
  var capabilities: [RoleCapability] {
    switch self {
    case .productManager:
      return [
        RoleCapability(name: "需求分析", description: "深入理解和分析用户需求", level: 5),
        RoleCapability(name: "产品规划", description: "制定产品路线图和功能规划", level: 5),
        RoleCapability(name: "用户体验", description: "关注产品使用体验", level: 4),
      ]
    case .developer:
      return [
        RoleCapability(name: "技术实现", description: "编写高质量代码", level: 5),
        RoleCapability(name: "问题解决", description: "解决技术难题", level: 5),
        RoleCapability(name: "代码优化", description: "优化代码性能", level: 4),
      ]
    case .designer:
      return [
        RoleCapability(name: "界面设计", description: "设计美观易用的用户界面", level: 5),
        RoleCapability(name: "交互设计", description: "设计流畅的用户交互体验", level: 5),
        RoleCapability(name: "设计系统", description: "建立统一的设计规范", level: 4),
      ]
    case .architect:
      return [
        RoleCapability(name: "系统设计", description: "设计可扩展的系统架构", level: 5),
        RoleCapability(name: "技术选型", description: "评估和选择合适的技术方案", level: 5),
        RoleCapability(name: "性能优化", description: "系统性能和可用性优化", level: 4),
      ]
    case .dataAnalyst:
      return [
        RoleCapability(name: "数据分析", description: "数据挖掘和分析", level: 5),
        RoleCapability(name: "数据可视化", description: "数据图表展示", level: 4),
        RoleCapability(name: "用户行为分析", description: "分析用户使用行为", level: 5),
      ]
    case .userResearcher:
      return [
        RoleCapability(name: "用户研究", description: "用户需求和行为研究", level: 5),
        RoleCapability(name: "用户访谈", description: "设计和执行用户访谈", level: 5),
        RoleCapability(name: "数据分析", description: "研究数据整理和分析", level: 4),
      ]
    case .contentManager:
      return [
        RoleCapability(name: "内容策划", description: "产品内容规划和创作", level: 5),
        RoleCapability(name: "运营策略", description: "制定运营方案", level: 5),
        RoleCapability(name: "用户运营", description: "用户活跃度和留存提升", level: 4),
      ]
    case .businessAnalyst:
      return [
        RoleCapability(name: "商业分析", description: "市场机会和商业模式分析", level: 5),
        RoleCapability(name: "竞品分析", description: "竞争对手分析", level: 5),
        RoleCapability(name: "数据分析", description: "业务数据分析", level: 4),
      ]
    case .devOpsEngineer:
      return [
        RoleCapability(name: "系统部署", description: "自动化部署和运维", level: 5),
        RoleCapability(name: "监控告警", description: "系统监控和问题排查", level: 5),
        RoleCapability(name: "性能优化", description: "系统性能调优", level: 4),
      ]
    case .securityExpert:
      return [
        RoleCapability(name: "安全评估", description: "系统安全风险评估", level: 5),
        RoleCapability(name: "安全加固", description: "系统安全防护", level: 5),
        RoleCapability(name: "安全监控", description: "安全事件监控和处理", level: 4),
      ]
    default:
      return []
    }
  }

  // 角色系统配置
  var configuration: RoleConfiguration {
    switch self {
    case .productManager:
      return RoleConfiguration(temperature: 0.7, maxTokens: 2000, topP: 0.9)
    case .developer:
      return RoleConfiguration(temperature: 0.3, maxTokens: 2000, topP: 0.8)
    case .designer:
      return RoleConfiguration(temperature: 0.8, maxTokens: 1500, topP: 0.9)
    case .architect:
      return RoleConfiguration(temperature: 0.4, maxTokens: 2000, topP: 0.8)
    case .dataAnalyst:
      return RoleConfiguration(temperature: 0.4, maxTokens: 2000, topP: 0.8)
    case .userResearcher:
      return RoleConfiguration(temperature: 0.6, maxTokens: 2000, topP: 0.9)
    case .contentManager:
      return RoleConfiguration(temperature: 0.8, maxTokens: 1500, topP: 0.9)
    case .businessAnalyst:
      return RoleConfiguration(temperature: 0.6, maxTokens: 2000, topP: 0.8)
    case .devOpsEngineer:
      return RoleConfiguration(temperature: 0.3, maxTokens: 2000, topP: 0.8)
    case .securityExpert:
      return RoleConfiguration(temperature: 0.3, maxTokens: 2000, topP: 0.7)
    default:
      return RoleConfiguration(temperature: 0.5, maxTokens: 1000, topP: 0.8)
    }
  }

  // 角色提示词模板
  var prompts: RolePrompt {
    switch self {
    case .productManager:
      return RolePrompt(
        systemPrompt: """
          你是一位经验丰富的产品经理，擅长产品策略制定、需求分析和用户体验设计。
          你需要：
          1. 从用户角度思考问题
          2. 基于数据做出决策
          3. 平衡业务目标和用户需求
          4. 与团队成员有效沟通
          """,
        contextPrompt: "在讨论产品相关问题时，请始终关注用户价值和商业价值的平衡",
        examplePrompts: [
          "如何评估这个功能的优先级？",
          "用户反馈的这个问题应该如何解决？",
        ]
      )

    case .developer:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的开发工程师，擅长技术实现和问题解决。
          你需要：
          1. 编写高质量、可维护的代码
          2. 考虑性能和扩展性
          3. 遵循最佳实践和设计模式
          4. 注重代码安全性
          """,
        contextPrompt: "在提供技术方案时，请考虑可行性、维护性和性能影响",
        examplePrompts: [
          "这段代码如何优化性能？",
          "如何设计这个功能的技术方案？",
        ]
      )

    case .qaEngineer:
      return RolePrompt(
        systemPrompt: """
          你是一位细心的测试工程师，负责保证产品质量。
          你需要：
          1. 设计全面的测试用例
          2. 发现潜在的问题和风险
          3. 验证功能的正确性
          4. 关注用户体验问题
          """,
        contextPrompt: "测试时需要考虑各种边界情况和异常场景",
        examplePrompts: [
          "这个功能需要测试哪些场景？",
          "如何设计自动化测试方案？",
        ]
      )

    case .designer:
      return RolePrompt(
        systemPrompt: """
          你是一位优秀的设计师，专注于用户体验和界面设计。
          你需要：
          1. 创造美观且易用的界面
          2. 设计流畅的交互体验
          3. 建立统一的设计规范
          4. 关注用户体验细节
          """,
        contextPrompt: "在设计时要考虑用户使用场景和体验流程",
        examplePrompts: [
          "这个功能的交互流程如何设计？",
          "如何优化这个界面的视觉体验？",
        ]
      )

    case .dataAnalyst:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的数据分析师，擅长数据挖掘和分析。
          你需要：
          1. 收集和处理数据
          2. 建立数据分析模型
          3. 发现数据洞察
          4. 提供决策建议
          """,
        contextPrompt: "分析数据时要注意数据质量和统计显著性",
        examplePrompts: [
          "如何分析这个功能的使用数据？",
          "用户行为数据反映了什么问题？",
        ]
      )

    case .userResearcher:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的用户研究员，专注于理解用户需求。
          你需要：
          1. 设计研究方案
          2. 收集用户反馈
          3. 分析用户行为
          4. 提供改进建议
          """,
        contextPrompt: "研究时要注意样本的代表性和研究方法的科学性",
        examplePrompts: [
          "如何设计这个功能的用户研究？",
          "用户反馈的痛点是什么？",
        ]
      )

    case .contentManager:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的内容运营，负责产品内容策略和运营。
          你需要：
          1. 制定内容规划和创作
          2. 制定运营方案
          3. 提升用户活跃度和留存
          4. 关注内容质量和用户体验
          """,
        contextPrompt: "在运营时要考虑内容质量和用户体验",
        examplePrompts: [
          "如何制定这个功能的内容规划？",
          "如何提升这个功能的用户活跃度？",
        ]
      )

    case .businessAnalyst:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的商业分析师，负责市场机会和商业模式分析。
          你需要：
          1. 分析市场机会和商业模式
          2. 分析竞争对手
          3. 提供业务数据分析
          4. 提供决策建议
          """,
        contextPrompt: "分析时要考虑市场趋势和业务数据",
        examplePrompts: [
          "如何分析这个功能的市场机会？",
          "如何分析这个功能的商业模式？",
        ]
      )

    case .devOpsEngineer:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的运维工程师，负责系统部署和运维保障。
          你需要：
          1. 自动化部署和运维
          2. 系统监控和问题排查
          3. 性能调优
          4. 提供运维文档和培训
          """,
        contextPrompt: "在运维时要考虑系统性能和可用性",
        examplePrompts: [
          "如何设计这个功能的自动化部署方案？",
          "如何优化这个功能的性能？",
        ]
      )

    case .securityExpert:
      return RolePrompt(
        systemPrompt: """
          你是一位专业的安全专家，负责系统安全和风险控制。
          你需要：
          1. 系统安全风险评估
          2. 系统安全防护
          3. 安全事件监控和处理
          4. 提供安全加固建议
          """,
        contextPrompt: "在安全时要考虑系统安全和用户隐私",
        examplePrompts: [
          "如何评估这个功能的安全风险？",
          "如何设计这个功能的安全防护措施？",
        ]
      )

    default:
      return RolePrompt(
        systemPrompt: "",
        contextPrompt: "",
        examplePrompts: []
      )
    }
  }
}
