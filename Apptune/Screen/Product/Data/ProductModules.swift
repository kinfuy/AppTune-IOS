import SwiftUI

struct ProductModules {
  static let groups: [ModuleGroup] = [
    ModuleGroup(
      title: "我的空间",
      description: "查看您参与的产品和活动",
      order: 2,
      modules: [
        ModuleDefinition(
          tab: .devCard,
          icon: "person.text.rectangle.fill",
          title: "开发名片",
          description: "展示您的开发者档案",
          color: .indigo,
          roles: ["developer", "admin"],
          badges: [],
          order: 1
        ),
        ModuleDefinition(
          tab: .myProducts,
          icon: "cube.fill",
          title: "我的产品",
          description: "查看和管理我的产品",
          color: .purple,
          roles: ["user", "developer", "admin"],
          badges: [],
          order: 2
        ),
        ModuleDefinition(
          tab: .joinedEvents,
          icon: "person.2.fill",
          title: "我参与的",
          description: "查看已参与的产品活动",
          color: .orange,
          roles: ["user", "developer", "admin"],
          badges: [],
          order: 3
        ),
      ]
    ),
    ModuleGroup(
      title: "创新工具",
      description: "激发创意的智能工具集",
      order: 3,
      modules: [
        ModuleDefinition(
          tab: .brainstormLab,
          icon: "brain.head.profile",
          title: "脑暴实验室",
          description: "AI驱动的创意激发工具",
          color: .pink,
          roles: ["user", "developer", "admin"],
          badges: [.pro, .beta],
          order: 1
        ),
        ModuleDefinition(
          tab: .productIncubator,
          icon: "leaf.fill",
          title: "产品孵化",
          description: "从创意到产品的孵化工具",
          color: .mint,
          roles: ["user", "developer", "admin"],
          badges: [.new, .pro],
          order: 2
        ),
        ModuleDefinition(
          tab: .copywritingFactory,
          icon: "text.book.closed.fill",
          title: "文案工厂",
          description: "生成高质量文案的智能工具",
          color: .green,
          roles: ["user", "developer", "admin"],
          badges: [],
          order: 3
        ),
        ModuleDefinition(
          tab: .competitorAnalysis,
          icon: "binoculars.fill",
          title: "竞品分析",
          description: "智能竞品分析与对标",
          color: .orange,
          roles: ["developer", "admin"],
          badges: [.new, .ai],
          order: 4
        ),
      ]
    ),
    ModuleGroup(
      title: "管理中心",
      description: "管理产品和活动的中心",
      order: 4,
      modules: [
        ModuleDefinition(
          tab: .myEvents,
          icon: "calendar.badge.plus",
          title: "活动管理",
          description: "查看和管理活动",
          color: .blue,
          roles: ["developer", "admin"],
          badges: [],
          order: 1
        ),
        ModuleDefinition(
          tab: .dataCenter,
          icon: "chart.bar.fill",
          title: "数据中心",
          description: "产品数据分析与洞察",
          color: .teal,
          roles: ["developer", "admin"],
          badges: [.new],
          order: 2
        ),
        ModuleDefinition(
          tab: .promotion,
          icon: "tag.fill",
          title: "推广中心",
          description: "管理和优化推广活动",
          color: .indigo,
          roles: ["developer", "admin"],
          badges: [],
          order: 3
        ),
        ModuleDefinition(
          tab: .review,
          icon: "checkmark.seal.fill",
          title: "审核中心",
          description: "审核产品和活动",
          color: .blue,
          roles: ["admin"],
          badges: [],
          order: 4
        ),
      ]
    ),
    ModuleGroup(
      title: "社区互动",
      description: "发现和参与社区活动",
      order: 1,
      modules: [
        ModuleDefinition(
          tab: .communityExperience,
          icon: "bubble.left.and.bubble.right.fill",
          title: "社区经验",
          description: "分享和获取产品开发经验",
          color: .blue,
          roles: ["user", "developer", "admin"],
          badges: [.new],
          order: 1
        ),
        ModuleDefinition(
          tab: .eventHall,
          icon: "building.2.fill",
          title: "活动大厅",
          description: "浏览和参与最新活动",
          color: .purple,
          roles: ["user", "developer", "admin"],
          badges: [],
          order: 2
        ),
      ]
    ),
  ]
}
