import SwiftUI
import Kingfisher
  
struct ImgLoader: View {
    let url: String
  
    init(_ img: String) {
        self.url = img
    }
      
    var body: some View {
        Group {
            // 检查 URL 是否以 http 或 https 开头
            if url.hasPrefix("http") {
                // 使用 Kingfisher 加载远程图片
                KFImage(URL(string: url))
                    .placeholder {
                        Image("empty")
                            .resizable()
                            .loading(true, size: 1)
                    }
                    .resizable()
                    .loadDiskFileSynchronously()
                    .fade(duration: 0.25)
            } else {
                // 加载本地图片
                Image(url)
                    .resizable()
            }
        }
    }
}
