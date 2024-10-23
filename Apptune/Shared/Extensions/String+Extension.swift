import SwiftUI

extension String {
  /// MARK 加载国际化语言
  public func t() -> String {
    let string = NSLocalizedString(self, comment: self)
    return string
  }
}
