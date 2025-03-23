import Foundation
import UIKit

@MainActor
class PublishProductViewModel: ObservableObject {
  @Published var isEditMode: Bool = false
  @Published var searchResults: [AppSearchInfo] = []

  @Published var id: String?
  @Published var productName: String = ""
  @Published var productDescription: String = ""
  @Published var price: String = ""
  @Published var iconUrl: String = ""
  @Published var link: String = ""
  @Published var category: Catalog = .effect
  @Published var appId: String = ""
  @Published var developer: String = ""
  @Published var bundleId: String = ""
  @Published var version: String = ""

  @Published var isLoading: Bool = false

  @Published var selectedApp: AppSearchInfo?

  @Published var selectedImage: UIImage? {
    didSet {
      if let image = selectedImage {
        uploadCustomImage(image)
      }
    }
  }

  var isValid: Bool {
    !productName.isEmpty && !productDescription.isEmpty && !iconUrl.isEmpty
  }

  var hasAppStoreInfo: Bool {
    !searchResults.isEmpty
  }

  func checkValid() -> String? {
    if !isValid {
      return "请输入完整的产品信息"
    }
    return nil
  }

  func fetchAppStoreInfo(name: String) async {
    guard !name.isEmpty else { return }

    isLoading = true
    do {
      searchResults = try await API.searchAppStore(keyword: name)
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

  @MainActor
  func publishProduct(success: @escaping () -> Void) async {
    isLoading = true
    do {
      let priceValue = Double(price)
      if isEditMode && id != nil {
        let _ = try await API.updateProduct(
          id: id!,
          name: productName,
          description: productDescription,
          icon: iconUrl,
          link: link,
          category: category,
          appId: appId.isEmpty ? nil : appId,
          developer: developer.isEmpty ? nil : developer,
          price: priceValue,
          bundleId: bundleId.isEmpty ? nil : bundleId,
          version: version.isEmpty ? nil : version
        )
      } else {
        try await API.publishProduct(
          name: productName,
          description: productDescription,
          icon: iconUrl,
          link: link,
          category: category,
          appId: appId.isEmpty ? nil : appId,
          developer: developer.isEmpty ? nil : developer,
          price: priceValue,
          bundleId: bundleId.isEmpty ? nil : bundleId,
          version: version.isEmpty ? nil : version
        )
      }

      isLoading = false
      success()
    } catch {
      isLoading = false
    }
  }

  func handleSelectedApp(_ app: AppSearchInfo) {
    self.productName = app.name
    self.productDescription = app.description
    self.iconUrl = app.iconUrl
    self.link = app.appStoreUrl
    self.category = .effect
    self.price = String(app.price)
    self.appId = app.appId
    self.developer = app.developer
    self.bundleId = app.bundleId
    self.version = app.version ?? ""
  }

  private func uploadCustomImage(_ image: UIImage) {
    Task {
      do {
        let url = try await API.uploadImage(image, extraData: ["type": "product"])
        await MainActor.run {
          self.iconUrl = url
        }
      } catch {
        print("Upload failed: \(error)")
        // 处理错误...
      }
    }
  }

  func editProduct(product: ProductInfo) {
    self.productName = product.name
    self.productDescription = product.description
    self.iconUrl = product.icon
    self.link = product.link ?? ""
    self.category = product.category
    self.isEditMode = true
  }
}
