import Kingfisher
import SwiftUI

// MARK: - Private Methods
enum ImageType {
  case remote
  case assets
  case local
}

private struct PreviewTapModifier: ViewModifier {
  let canPreview: Bool
  @EnvironmentObject var notice: NoticeManager
  let url: String
  let imageType: ImageType

  func body(content: Content) -> some View {
    ZStack {
      content

      if canPreview {
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            notice.open(
              open: .imagePreview(url: url, imageType: imageType)
            )
          }
          .allowsHitTesting(canPreview)
      }
    }
  }
}

@MainActor
struct ImgLoader: View {
  @EnvironmentObject var notice: NoticeManager
  private let url: String
  private let placeholder: String = "empty"
  private let contentMode: SwiftUI.ContentMode
  private let canPreview: Bool
  @State private var imageRatio: CGFloat = 1.0
  @State private var loadFailed: Bool = false

  // MARK: - Init
  init(_ img: String, contentMode: SwiftUI.ContentMode = .fill, canPreview: Bool = false) {
    self.url = img
    self.contentMode = contentMode
    self.canPreview = canPreview
  }

  // MARK: - Body
  var body: some View {
    Group {
      if loadFailed {
        Image(systemName: "photo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.gray)
      } else {
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
    .aspectRatio(imageRatio, contentMode: contentMode)
    .modifier(
      PreviewTapModifier(
        canPreview: canPreview,
        url: url,
        imageType: getImageType(url)
      ))
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
        loadFailed = false
        let size = result.image.size
        imageRatio = size.width / size.height
      }
      .onFailure { error in
        loadFailed = true
        imageRatio = 1.0
      }
      .resizable()
      .loadDiskFileSynchronously()
      .fade(duration: 0.25)
  }
}

struct ImagePreviewView: View {
  let url: String
  let imageType: ImageType
  let id: String
  @Environment(\.displayScale) private var displayScale
  @EnvironmentObject var notice: NoticeManager

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Group {
          switch imageType {
          case .remote:
            KFImage(URL(string: url))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(
                maxWidth: min(geometry.size.width * 0.9, geometry.size.height * 0.9),
                maxHeight: min(geometry.size.width * 0.9, geometry.size.height * 0.9)
              )
          case .assets:
            KFImage(URL(string: "\(IMAGE_SERVER_URL)\(url)"))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(
                maxWidth: min(geometry.size.width * 0.9, geometry.size.height * 0.9),
                maxHeight: min(geometry.size.width * 0.9, geometry.size.height * 0.9)
              )
          case .local:
            Image(url)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(
                maxWidth: min(geometry.size.width * 0.9, geometry.size.height * 0.9),
                maxHeight: min(geometry.size.width * 0.9, geometry.size.height * 0.9)
              )
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black.opacity(0.9))
      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
      .onTapGesture {
        notice.close(id: id)
      }
    }
  }
}
