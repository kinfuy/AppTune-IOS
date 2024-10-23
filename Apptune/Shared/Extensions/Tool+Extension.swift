//
//  Tool+Extension.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/11.
//

import SwiftUI

extension View {
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        modifier: (Self) -> Content
    ) -> some View {
        Group {
            if condition {
                modifier(self)
            } else {
                self
            }
        }
    }

    func loading(_ isLoading: Bool, size: CGFloat = 1.5) -> some View {
        Group {
            if isLoading {
                self.overlay(content: {
                    VStack {
                        ProgressView()
                            .scaleEffect(size, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                })
            } else {
                self
            }
        }
    }
}
