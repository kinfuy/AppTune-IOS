import SwiftUI

func attributedString(str:String) -> AttributedString {
    var attributedString = AttributedString(str)
    attributedString.link = nil
    return attributedString
}


extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func linearGradient(_ startColor: Color, _ endColor: Color) -> some View {
        background(
            LinearGradient(
                gradient: Gradient(colors: [startColor, endColor]), startPoint: .top,
                endPoint: .bottom)
        )
    }

    func loading(_ isLoading: Bool, _ size: CGFloat = 1.5) -> some View {
        Group {
            if isLoading {
                self.overlay(content: {
                    VStack {
                        ProgressView()
                            .scaleEffect(size, anchor: .center)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color.theme)
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                })
            } else {
                self
            }
        }
    }
}
