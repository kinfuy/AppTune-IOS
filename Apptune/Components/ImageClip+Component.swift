import Mantis
import SwiftUI

struct ImageClipComponent: View {
  // MARK: - Properties
  let selectedImage: UIImage
  var onSelect: ((_ image: UIImage) -> Void)?
  var onCancel: (() -> Void)?
  @State private var isCropViewPresented = false

  // MARK: - Body
  var body: some View {
    CropViewControllerRepresentable(
      image: selectedImage,
      completion: { croppedImage in
        if let image = croppedImage {
          onSelect?(image)
        } else {
          onCancel?()
        }
      }
    )
    .ignoresSafeArea()
  }
}

// MARK: - Mantis CropViewController Representative

struct CropViewControllerRepresentable: UIViewControllerRepresentable {
  let image: UIImage
  let completion: (UIImage?) -> Void

  func makeUIViewController(context: Context) -> UIViewController {
    var config = Mantis.Config()
    config.cropToolbarConfig.ratioCandidatesShowType = .presentRatioList
    let cropViewController = Mantis.cropViewController(image: image, config: config)
    cropViewController.delegate = context.coordinator
    return cropViewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(completion: completion)
  }

  class Coordinator: NSObject, CropViewControllerDelegate {
    let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
      self.completion = completion
    }

    func cropViewControllerDidCrop(
      _ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation,
      cropInfo: CropInfo
    ) {
      completion(cropped)
    }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
      completion(nil)
    }

    func cropViewControllerDidFailToCrop(
      _ cropViewController: CropViewController, original: UIImage
    ) {
      completion(nil)
    }

    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
      // 空实现
    }

    func cropViewControllerDidEndResize(
      _ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo
    ) {
      // 空实现
    }
  }
}

// MARK: - Preview

struct ImageClipComponent_Previews: PreviewProvider {
  static var previews: some View {
    ImageClipComponent(selectedImage: UIImage(named: "user")!)
  }
}
