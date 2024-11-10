//
//  Empty.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/9/12.
//

import SwiftUI

struct EmptyView: View {
    var text:String = "暂无数据"
    var image:String = "empty"
    var size: CGFloat = 200
    var body: some View {
        VStack {
            if image != "" {
                Image(image)
                    .resizable()
                    .frame(width: size, height: size)
            }
            if(text != "" ){
                Text(text).foregroundColor(.secondary)
            }
        }.frame(maxHeight: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/)
            .padding()
    }
}
