import SwiftUI

// 添加 ImagePicker 视图
struct ImagePicker: UIViewControllerRepresentable {
  @Binding var image: UIImage?
  var onDismiss: (() -> Void)?  // 添加关闭回调

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .photoLibrary
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        parent.image = image
      }
      parent.onDismiss?()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.onDismiss?()
    }
  }
}
