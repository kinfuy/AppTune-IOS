import SwiftUI

struct ProductModules {
  static let groups: [ModuleGroup] = [
    ModuleGroup(
      title: "我的空间",
      description: "查看您参与的产品和活动",
      order: 2,
      modules: [
        // ModuleDefinition(
        //   tab: .devCard,
        //   icon: "person.text.rectangle.fill",
        //   title: "开发名片",
        //   description: "展示您的开发者档案",
        //   color: .indigo,
        //   roles: ["developer", "admin"],
        //   badges: [.pending],
        //   order: 1,
        //   isEnabled: false
        // ),
        ModuleDefinition(
          tab: .myProducts,
          icon: "cube.fill",
          title: "我的产品",
          description: "查看和管理我的产品",
          color: .purple,
          roles: [],
          badges: [],
          order: 2,
          isEnabled: true
        ),
        ModuleDefinition(
          tab: .myEvents,
          icon: "calendar.badge.plus",
          title: "我的活动",
          description: "查看和管理活动",
          color: .blue,
          roles: ["developer", "admin"],
          badges: [],
          order: 3,
          isEnabled: true
        ),
        ModuleDefinition(
          tab: .joinedEvents,
          icon: "person.2.fill",
          title: "我参与的",
          description: "查看已参与的产品活动",
          color: .orange,
          roles: [],
          badges: [],
          order: 4,
          isEnabled: true
        ),
        ModuleDefinition(
          tab: .promotion,
          icon: "tag.fill",
          title: "促销码",
          description: "管理和优化促销码",
          color: .indigo,
          roles: ["developer", "admin"],
          badges: [],
          order: 6,
          isEnabled: true
        ),
      ]
    ),
    ModuleGroup(
      title: "创新工具",
      description: "激发创意的智能工具集",
      order: 3,
      modules: [
        // ModuleDefinition(
        //   tab: .brainstormLab,
        //   icon: "brain.head.profile",
        //   title: "头脑风暴",
        //   description: "AI驱动的创意激发工具",
        //   color: .pink,
        //   roles: [],
        //   badges: [.pro, .beta],
        //   order: 1,
        //   isEnabled: true
        // ),
        ModuleDefinition(
          tab: .productIncubator,
          icon: "leaf.fill",
          title: "灵感工坊",
          description: "灵感碰撞，创意孵化",
          color: .mint,
          roles: [],
          badges: [.pending],
          order: 2,
          isEnabled: false
        ),
        ModuleDefinition(
          tab: .copywritingFactory,
          icon: "text.book.closed.fill",
          title: "文案工厂",
          description: "生成高质量文案的智能工具",
          color: .green,
          roles: [],
          badges: [.pending],
          order: 3,
          isEnabled: false
        ),
      ]
    ),
    ModuleGroup(
      title: "管理中心",
      description: "管理产品和活动的中心",
      order: 4,
      modules: [
        ModuleDefinition(
          tab: .review,
          icon: "checkmark.seal.fill",
          title: "审核中心",
          description: "审核产品和活动",
          color: .blue,
          roles: ["admin"],
          badges: [],
          order: 3,
          isEnabled: true
        )
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
          roles: [],
          badges: [.new],
          order: 2,
          isEnabled: true
        ),
        ModuleDefinition(
          tab: .eventHall,
          icon: "building.2.fill",
          title: "活动大厅",
          description: "浏览和参与最新活动",
          color: .purple,
          roles: [],
          badges: [],
          order: 1,
          isEnabled: true
        ),
        ModuleDefinition(
          tab: .productShow,
          icon: "app.badge.fill",
          title: "产品发布会",
          description: "浏览社区发布的产品",
          color: .orange,
          roles: [],
          badges: [.new],
          order: 3,
          isEnabled: true
        ),
      ]
    ),
  ]
}
