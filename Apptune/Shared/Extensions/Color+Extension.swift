import SwiftUI

extension Color: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let colorHexString = try container.decode(String.self)

    if colorHexString.count == 7 {  // No alpha information
      self.init(hex: colorHexString)
    } else if colorHexString.count == 9 {  // Has alpha information
      self.init(hexWithAlpha: colorHexString)
    } else {
      self.init(.clear)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.toHex)
  }

  var toHex: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    let uiColor = UIColor(self)
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    let redInt = Int(red * 255)
    let greenInt = Int(green * 255)
    let blueInt = Int(blue * 255)
    let alphaInt = Int(alpha * 255)

    return String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
  }

  public init(hex: String) {
    if hex.count == 7 {
      self.init(hexWithAlpha: hex + "FF")
    } else {
      self.init(hexWithAlpha: hex)
    }
  }

  public init(hexWithAlpha: String) {
    var hexSanitized = hexWithAlpha.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgba: UInt64 = 0

    Scanner(string: hexSanitized).scanHexInt64(&rgba)

    let red = Double((rgba & 0xFF00_0000) >> 24) / 255.0
    let green = Double((rgba & 0x00FF_0000) >> 16) / 255.0
    let blue = Double((rgba & 0x0000_FF00) >> 8) / 255.0
    let alpha = Double(rgba & 0x0000_00FF) / 255.0

    self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }
}
