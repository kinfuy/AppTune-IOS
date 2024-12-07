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

    // 尝试编码，失败则返回空字典
    guard let data = try? encoder.encode(self),
      let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      print("⚠️ 转换失败")
      return [:]
    }

    // 过滤并转换值，忽略失败的情况
    return dictionary.compactMapValues { value in
      if let date = value as? Date {
        return ISO8601DateFormatter().string(from: date)
      }
      return value
    }
  }
}
