//
//  PreCodePicker+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct PreCodePickerSheet: View {
  @EnvironmentObject var promotionService: PromotionService
  var productId: String
  @State private var selectedCodes: [PromotionCode] = []

  var onSelect: ((_ codes: [PromotionCode]) -> Void)?
  var onCancel: (() -> Void)?

  var body: some View {
    VStack(spacing: 0) {

    }
    // sheet 高度

  }
}

#Preview {
  Text("")
    .sheet(isPresented: .constant(true)) {
      PreCodePickerSheet(
        productId: "123",
        onSelect: { codes in
          print(codes)
        },
        onCancel: {
          print("cancel")
        }
      )
      .presentationDetents([.fraction(0.68)])
      //  sheet 指示器
    }

}
