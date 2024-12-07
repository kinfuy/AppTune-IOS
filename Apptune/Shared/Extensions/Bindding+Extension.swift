import SwiftUI

extension Binding {
  static func ?? <T>(optional: Self, defaultValue: T) -> Binding<T> where Value == T? {
    Binding<T>(
      get: { optional.wrappedValue ?? defaultValue },
      set: { optional.wrappedValue = $0 }
    )
  }
}
