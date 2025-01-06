import SwiftUI
import WebKit

class WebViewManager: ObservableObject {
  @Published var currentURL: URL? = nil
  @Published var showWebView: Bool = false
}

// 添加 WebView 协调器来处理加载状态
class WebViewCoordinator: NSObject, WKNavigationDelegate {
  @Binding var isLoading: Bool
  @Binding var pageTitle: String

  init(isLoading: Binding<Bool>, pageTitle: Binding<String>) {
    _isLoading = isLoading
    _pageTitle = pageTitle
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    isLoading = true
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    isLoading = false
    pageTitle = webView.title ?? ""
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    isLoading = false
  }
}

struct WebView: View {
  @EnvironmentObject var router: Router
  let url: String
  let title: String?
  @State private var isLoading = true
  @State private var pageTitle: String = ""

  var body: some View {
    VStack(spacing: 0) {
      // 自定义顶部导航栏
      HStack {
        Button {
          router.back()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(.primary)
            .font(.system(size: 17, weight: .medium))
        }

        Spacer()

        Text(title ?? pageTitle)
          .font(.system(size: 17, weight: .semibold))
          .lineLimit(1)  // 限制标题为单行
          .truncationMode(.tail)  // 超出部分显示省略号
          .frame(maxWidth: UIScreen.main.bounds.width - 120)  // 限制标题最大宽度

        Spacer()

        // 添加一个占位视图，保持标题居中
        Image(systemName: "chevron.left")
          .opacity(0)
      }
      .padding(.horizontal, 16)
      .frame(height: 44)

      // 添加一条分割线
      Divider()

      ZStack {
        if let u = URL(string: url) {
          // WebView 内容
          WebViewRepresentable(url: u, isLoading: $isLoading, pageTitle: $pageTitle)
            .ignoresSafeArea(edges: .all)  // 忽略安全区域，隐藏原生导航

          // 加载动画
          if isLoading {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
              .scaleEffect(1.2)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color.black.opacity(0.05))
          }
        }
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .navigationBarHidden(true)
  }
}

// WebView 实现部分
private struct WebViewRepresentable: UIViewRepresentable {
  let url: URL
  @Binding var isLoading: Bool
  @Binding var pageTitle: String

  func makeCoordinator() -> WebViewCoordinator {
    WebViewCoordinator(isLoading: $isLoading, pageTitle: $pageTitle)
  }

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.allowsBackForwardNavigationGestures = true
    webView.navigationDelegate = context.coordinator
    let request = URLRequest(url: url)
    webView.load(request)
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    // 移除这里的加载请求
  }
}

#Preview("不同网站预览") {
  Group {
    WebView(
      url: "https://www.apple.com",
      title: nil
    )
    .environmentObject(Router())
  }
}
