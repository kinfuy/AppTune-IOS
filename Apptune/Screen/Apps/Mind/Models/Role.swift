import SwiftUI

protocol Role: Identifiable, Hashable {
  var name: String { get }
  var icon: String { get }
  var description: String { get }
  var backgroundColor: Color { get }
  var isSelectable: Bool { get }
}

// 扩展 ProductRole 实现 Role 协议
extension ProductRole: Role {
  var name: String {
    rawValue
  }
}

// 扩展 CustomRole 实现 Role 协议
extension CustomRole: Role {
  var isSelectable: Bool {
    true
  }
}
