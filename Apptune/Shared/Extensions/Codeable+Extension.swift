//
//  Codeable+Extension.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/7.
//

import SwiftUI

extension Encodable {
  func asDictionary() -> [String: Any] {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys

    // 尝试编码，失败则返回空字典
    guard let data = try? encoder.encode(self),
      let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      print("⚠️ 编码失败")
      return [:]
    }

    return dictionary  // 直接返回转换后的字典，不需要额外处理
  }
}
