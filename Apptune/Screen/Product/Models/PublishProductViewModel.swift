import Foundation
import UIKit

@MainActor
class PublishProductViewModel: ObservableObject {
  @Published var searchResults: [AppSearchInfo] = []

  @Published var productName: String = ""
  @Published var productDescription: String = ""
  @Published var price: String = ""
  @Published var iconUrl: String = ""
  @Published var link: String = ""

  @Published var isLoading: Bool = false

  @Published var selectedApp: AppSearchInfo?

  var isValid: Bool {
    !productName.isEmpty && !productDescription.isEmpty && !price.isEmpty
      && (Double(price) ?? 0) >= 0
  }

  var hasAppStoreInfo: Bool {
    !searchResults.isEmpty
  }

  func fetchAppStoreInfo(name: String) async {
    guard !name.isEmpty else { return }

    isLoading = true
    do {
      searchResults = try await ProductAPI.shared.searchAppStore(keyword: name)
      isLoading = false
    } catch {
      searchResults = []
      isLoading = false
    }
  }

  func selectApp(_ app: AppSearchInfo) {
    selectedApp = app
    productName = app.name
    productDescription = app.description
    iconUrl = app.iconUrl
    link = app.appStoreUrl
  }

  func publishProduct() async {
    guard isValid else {
      return
    }

    isLoading = true
    isLoading = false
  }

  func handleSelectedApp(_ app: AppSearchInfo) {
    self.iconUrl = app.iconUrl
    self.productName = app.name
    self.link = app.appStoreUrl
    self.productDescription = app.description
    self.price = String(app.price)

  }
}
