import UIKit

class Tap {
  static let shared = Tap()

  private init() {}

  func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
  }

  func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
  }
}
