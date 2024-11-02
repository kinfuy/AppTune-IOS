import Foundation
import UIKit

struct UploadResponse: Decodable {
  var url: String
}

class FileAPI {
  static let shared = FileAPI()
  private let apiManager = APIManager.shared

  func uploadImage(_ image: UIImage, quality: CGFloat = 0.5) async throws -> String {
    guard let imageData = image.jpegData(compressionQuality: quality) else {
      throw APIError.serveError(code: "999999", message: "图片处理失败")
    }

    // 创建 multipart/form-data 请求
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/upload/image",
      method: "POST",
      body: nil
    )

    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // 构建请求体
    var body = Data()

    // 添加图片数据
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append(
      "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(
        using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n".data(using: .utf8)!)

    // 结束标记
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    // 发送请求
    let response: UploadResponse = try await apiManager.session.data(for: request)
    return response.url
  }

  func uploadImages(_ images: [UIImage], quality: CGFloat = 0.5) async throws -> [String] {
    var urls: [String] = []

    for image in images {
      let url = try await uploadImage(image, quality: quality)
      urls.append(url)
    }

    return urls
  }

  // 上传头像
  func uploadAvatar(_ imageData: Data) async throws -> String {
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = try apiManager.createRequest(
      url: "\(BASR_SERVE_URL)/file/upload",
      method: "POST",
      body: nil
    )

    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append(
      "Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n".data(
        using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    let response: UploadResponse = try await apiManager.session.data(for: request)
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
