//
//  UIPasteboard+Util.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/6.
//

import UIKit

// MARK: - UIPasteboard 扩展
extension UIPasteboard {

  /// 读取剪贴板中的文本内容
  /// - Returns: 返回剪贴板中的文本,如果为空则返回 nil
  func getText() -> String? {
    return self.string
  }

  /// 写入文本到剪贴板
  /// - Parameter text: 要写入的文本内容
  func setText(_ text: String) {
    self.string = text
  }

  /// 清空剪贴板内容
  func clear() {
    self.items = []
  }

  /// 检查剪贴板是否包含文本内容
  /// - Returns: 如果包含文本返回 true,否则返回 false
  func hasText() -> Bool {
    return self.hasStrings
  }
}
