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
  case designer = 15
  case messageCenter = 16

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
    case .designer:
      return .community
    case .messageCenter:
      return .messageCenter
    }
  }
}
