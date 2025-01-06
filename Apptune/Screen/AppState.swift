import SwiftUI

struct AppInfo: Codable {
  let version: String
}

struct AppStoreResponse: Codable {
  let resultCount: Int
  let results: [AppInfo]
}

@MainActor
class AppState: ObservableObject {
  static let shared = AppState()
  let skinVersion = UserDefaults.standard.string(forKey: "skinVersion") ?? ""
  @Published var latestVersion: String = ""
  @Published var currentVersion: String = ""

  var isSkinVersion: Bool {

    if self.skinVersion == "" {
      return false
    }

    if self.skinVersion == self.latestVersion {
      return true
    }

    let skin = self.latestVersion.compare(self.skinVersion, options: .numeric) == .orderedDescending

    return skin
  }

  func checkForUpdate(ignoreSkin: Bool = false, completion: @escaping (Bool) -> Void = { _ in }) {
    self.currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let urlString = "https://itunes.apple.com/lookup?bundleId=kinfuy.Apptune"
    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      completion(false)
      return
    }
    URLSession.shared.dataTask(with: url) { data, _, _ in
      if let data = data {
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(AppStoreResponse.self, from: data) {
          if let appInfo = response.results.first {
            DispatchQueue.main.async {
              self.latestVersion = appInfo.version
              let updateAvailable =
                self.latestVersion.compare(self.currentVersion, options: .numeric)
                == .orderedDescending
              if updateAvailable {
                if !self.isSkinVersion || ignoreSkin {
                  _ = NoticeManager.shared.open(open: .version(VERSION_NOTICE_ID))
                  completion(true)
                  return
                }
              }
            }
          }
        }
      }
      completion(false)
    }.resume()
  }

}
