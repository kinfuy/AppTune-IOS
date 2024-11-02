import SwiftUI

public class Defaults: ObservableObject {
  @AppStorage("language") public var language: String = "简体中文"
  @AppStorage("showGuide") public var showGuide: Bool = true
  @AppStorage("allowNotice") public var allowNotice: Bool = false
  @AppStorage("skinVersion") public var skinVersion: String = ""
  @AppStorage("isAgreeMent") public var isAgreeMent: Bool = false
  @AppStorage("loginEmail") public var isLogin: String = ""
  @AppStorage("accessToken") public var token: String = ""
  @AppStorage("refreshToken") public var refreshToken: String = ""

  public static let shared = Defaults()
}

@propertyWrapper
public struct Default<T>: DynamicProperty {
  @ObservedObject private var defaults: Defaults
  private let keyPath: ReferenceWritableKeyPath<Defaults, T>
  public init(_ keyPath: ReferenceWritableKeyPath<Defaults, T>, defaults: Defaults = .shared) {
    self.keyPath = keyPath
    self.defaults = defaults
  }

  public var wrappedValue: T {
    get { defaults[keyPath: keyPath] }
    nonmutating set { defaults[keyPath: keyPath] = newValue }
  }

  public var projectedValue: Binding<T> {
    Binding(
      get: { defaults[keyPath: keyPath] },
      set: { value in
        defaults[keyPath: keyPath] = value
      }
    )
  }
}
