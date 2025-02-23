import Foundation

class SelectChatViewModel: ObservableObject {
  @Published var customRoles: Set<ProductRole> = []

  func toggleCustomRole(_ role: ProductRole) {
    if customRoles.contains(role) {
      customRoles.remove(role)
    } else {
      customRoles.insert(role)
    }
  }

  func getActiveRoles(from roles: [ProductRole]) -> Set<ProductRole> {
    var roleSet = Set(roles)
    roleSet.insert(.user)  // 添加用户角色
    return roleSet
  }
}
