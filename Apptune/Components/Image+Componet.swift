import Kingfisher
import SwiftUI

@MainActor
struct ImgLoader: View {
  private let url: String
  private let placeholder: String = "empty"
  private let contentMode: SwiftUI.ContentMode
  @State private var imageRatio: CGFloat = 1.0

  // MARK: - Init
  init(_ img: String, contentMode: SwiftUI.ContentMode = .fill) {
    self.url = img
    self.contentMode = contentMode
  }

  // MARK: - Body
  var body: some View {
    Group {
      switch getImageType(url) {
      case .remote:
        remoteImage
      case .assets:
        assetImage
      case .local:
        localImage
      }
    }
    .aspectRatio(imageRatio, contentMode: contentMode)
  }

  // MARK: - Private Methods
  private enum ImageType {
    case remote
    case assets
    case local
  }

  private func getImageType(_ url: String) -> ImageType {
    if url.hasPrefix("http") { return .remote }
    if url.hasPrefix("assets") { return .assets }
    return .local
  }

  // MARK: - Image Views
  private var remoteImage: some View {
    kfImage(url)
  }

  private var assetImage: some View {
    kfImage("\(IMAGE_SERVER_URL)\(url)")
  }

  private var localImage: some View {
    Image(url)
      .resizable()
      .aspectRatio(contentMode: contentMode)
  }

  private func kfImage(_ urlString: String) -> some View {
    KFImage(URL(string: urlString))
      .placeholder {
        Image(placeholder)
          .resizable()
          .loading(true, size: 1)
      }
      .onSuccess { result in
        let size = result.image.size
        imageRatio = size.width / size.height
      }
      .resizable()
      .loadDiskFileSynchronously()
      .fade(duration: 0.25)
  }
}
