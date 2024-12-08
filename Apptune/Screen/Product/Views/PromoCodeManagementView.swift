import SwiftUI

struct PromoCodeManagementView: View {
  @StateObject private var viewModel = PromoCodeViewModel()

  var body: some View {
    List {
      ForEach(viewModel.promoCodes) { code in
        PromoCodeRow(code: code)
      }
    }
    .navigationTitle("促销码管理")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("添加") {
          viewModel.showAddPromoCode = true
        }
      }
    }
    .sheet(isPresented: $viewModel.showAddPromoCode) {
      AddPromoCodeView(viewModel: viewModel)
    }
  }
}
