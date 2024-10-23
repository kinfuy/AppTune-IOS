import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    // 确保只有当堆栈中有多个视图控制器时才进行判断
    guard viewControllers.count > 1 else {
      return false
    }

    return true
  }
}
