import SwiftUI

struct RadioButton: View {
  @Binding private var isSelected: Bool
  private let label: String
  private var isDisabled: Bool = false

  init(isSelected: Binding<Bool>, label: String = "") {
    self._isSelected = isSelected
    self.label = label
  }

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      circleView
      labelView
    }
    .contentShape(Rectangle())
    .onTapGesture { isSelected = true }
    .disabled(isDisabled)
  }
}

extension RadioButton {
  @ViewBuilder fileprivate var labelView: some View {
    if !label.isEmpty {  // Show label if label is not empty
      Text(label)
        .foregroundColor(labelColor)
    }
  }

  @ViewBuilder fileprivate var circleView: some View {
    Circle()
      .fill(innerCircleColor)  // Inner circle color
      .padding(4)
      .overlay(
        Circle()
          .stroke(outlineColor, lineWidth: 1)
      )  // Circle outline
      .frame(width: 20, height: 20)
  }
}

extension RadioButton {
  fileprivate var innerCircleColor: Color {
    guard isSelected else { return Color.clear }
    if isDisabled { return Color.gray.opacity(0.6) }
    return Color.theme
  }

  fileprivate var outlineColor: Color {
    if isDisabled { return Color.gray.opacity(0.6) }
    return isSelected ? Color.theme : Color.gray
  }

  fileprivate var labelColor: Color {
    return isDisabled ? Color.gray.opacity(0.6) : Color.black
  }
}

extension RadioButton {
  func disabled(_ value: Bool) -> Self {
    var view = self
    view.isDisabled = value
    return view
  }
}
