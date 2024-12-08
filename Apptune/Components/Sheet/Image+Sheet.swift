//
//  Image+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/24.
//

import SwiftUI

struct ImageSheet: View {
  @EnvironmentObject var sheet: SheetManager
  @State private var selectedImage: UIImage?
  var onSelect: ((_ image: UIImage) -> Void)?
  var onCancel: (() -> Void)?
  var body: some View {
    VStack {
      ImagePicker(image: $selectedImage)
        .onChange(of: selectedImage) { _, newItem in
          if let image = newItem {
            onSelect?(image)
          }
        }
    }
  }
}

#Preview {
  Text("ss")
    .sheet(isPresented: .constant(true)) {
      ImageSheet()
    }
}
