//
//  ProductView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/16.
//

import SwiftUI

struct ProductView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ProductView()
}
