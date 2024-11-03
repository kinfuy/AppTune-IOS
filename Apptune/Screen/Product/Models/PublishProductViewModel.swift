import Foundation
import UIKit

@MainActor
final class PublishProductViewModel: ObservableObject {
  @Published var productName: String = ""
  @Published var productDescription: String = ""
  @Published var price: String = ""
  @Published var stock: String = ""
  @Published var category: Catalog = .all
  @Published var isAvailable: Bool = true
  @Published var productImage: UIImage?
  @Published var showImagePicker: Bool = false

  func publishProduct() async {
    // TODO: 实现产品发布逻辑
  }
}
