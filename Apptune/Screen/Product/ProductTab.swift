enum ProductTab: Int, CaseIterable {
  case joinedEvents = 0
  case myProducts = 1
  case myEvents = 2
  case review = 3
  case promotion = 4
  case brainstormLab = 5
  case copywritingFactory = 6
  case modelManagement = 7
  case devCard = 8
  case productIncubator = 9
  case dataCenter = 10
  case competitorAnalysis = 11
  case communityExperience = 12
  case eventHall = 13
  case productShow = 14

  var title: String {
    switch self {
    case .joinedEvents:
      return "我的参与"
    case .myProducts:
      return "我的产品"
    case .myEvents:
      return "我的活动"
    case .review:
      return "待审核"
    case .promotion:
      return "促销码"
    case .brainstormLab:
      return "脑暴实验室"
    case .copywritingFactory:
      return "文案工厂"
    case .modelManagement:
      return "模型管理"
    case .devCard:
      return "开发名片"
    case .productIncubator:
      return "产品孵化器"
    case .dataCenter:
      return "数据中心"
    case .competitorAnalysis:
      return "竞品分析"
    case .communityExperience:
      return "社区经验"
    case .eventHall:
      return "活动大厅"
    case .productShow:
      return "产品发布会"
    }
  }

  var route: GeneralRouterDestination {
    switch self {
    case .joinedEvents:
      return .joinedActive
    case .myProducts:
      return .myProduct
    case .myEvents:
      return .myActive
    case .review:
      return .reviewCenter
    case .promotion:
      return .promotion
    case .brainstormLab:
      return .selectChat
    case .copywritingFactory:
      return .community
    case .modelManagement:
      return .community
    case .devCard:
      return .community
    case .productIncubator:
      return .community
    case .dataCenter:
      return .community
    case .competitorAnalysis:
      return .community
    case .communityExperience:
      return .community
    case .eventHall:
      return .activeCenter
    case .productShow:
      return .productShow
    }
  }
}
