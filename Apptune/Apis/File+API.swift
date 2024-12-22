import Foundation
import UIKit

// MARK: - Models
struct UploadResponse: Decodable {
  var url: String
}

// MARK: - API Methods
extension API {
  static func uploadImage(
    _ image: UIImage, quality: CGFloat = 0.5, extraData: [String: String]? = nil
  ) async throws -> String {
    guard let imageData = image.jpegData(compressionQuality: quality) else {
      throw APIError.serveError(code: "999999", message: "图片处理失败")
    }

    let boundary = "Boundary-\(UUID().uuidString)"
    var request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/file/upload",
      method: "POST",
      body: nil
    )

    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    // 添加图片数据
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
    body.append("Content-Type: image/jpeg\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")

    // 添加额外参数
    if let extraData = extraData {
      for (key, value) in extraData {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append(value)
        body.append("\r\n")
      }
    }

    body.append("--\(boundary)--\r\n")
    request.httpBody = body

    let response: UploadResponse = try await API.shared.session.data(for: request)
    return response.url
  }

  static func uploadImages(
    _ images: [UIImage], quality: CGFloat = 0.5, extraData: [String: String]? = nil
  ) async throws -> [String] {
    var urls: [String] = []
    for image in images {
      let url = try await uploadImage(image, quality: quality, extraData: extraData)
      urls.append(url)
    }
    return urls
  }

  static func uploadAvatar(_ imageData: Data, loading: Bool = false) async throws -> String {
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = try API.shared.createRequest(
      url: "\(BASR_SERVE_URL)/file/upload",
      method: "POST",
      body: nil
    )

    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n")
    body.append("Content-Type: image/jpeg\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")

    request.httpBody = body

    let response: UploadResponse = try await API.shared.session.data(for: request, loading: loading)
    return response.url
  }
}

// MARK: - Helper Extensions
extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}
