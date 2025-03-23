import Foundation
import Security

class KeychainManager {
  static let shared = KeychainManager()

  private init() {}

  // 保存密码到 Keychain
  func savePassword(email: String, password: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: email,
      kSecValueData as String: password.data(using: .utf8)!,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
    ]

    // 先删除已存在的密码
    SecItemDelete(query as CFDictionary)

    // 保存新密码
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
  }

  // 从 Keychain 读取密码
  func getPassword(email: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: email,
      kSecReturnData as String: true,
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess,
      let data = result as? Data,
      let password = String(data: data, encoding: .utf8)
    {
      return password
    }
    return nil
  }

  // 删除 Keychain 中的密码
  func deletePassword(email: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: email,
    ]

    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess
  }
}
