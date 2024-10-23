//
//  ToggleStyle+Extension.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/15.
//

import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .theme : .gray)
            }
            .frame(width: 5, height: 5)
        })
    }
}

extension ToggleStyle where Self == iOSCheckboxToggleStyle {
    internal static var square: Self { Self() }
}
