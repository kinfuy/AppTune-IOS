import Kingfisher
import SwiftUI

@MainActor
struct ImgLoader: View {
  private let url: String
  private let placeholder: String = "empty"

  // MARK: - Init
  init(_ img: String) {
    self.url = img
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
  }

  private func kfImage(_ urlString: String) -> some View {
    KFImage(URL(string: urlString))
      .placeholder {
        Image(placeholder)
          .resizable()
          .loading(true, size: 1)
      }
      .resizable()
      .loadDiskFileSynchronously()
      .fade(duration: 0.25)
  }
}
