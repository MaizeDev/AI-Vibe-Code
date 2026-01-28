import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let html: String
    let scrollPercentage: Double
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // 允许访问本地文件
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 1. HTML 更新
        if context.coordinator.lastHtml != html {
            // 关键修改：传入 Bundle 的 URL 作为 baseURL
            // 这样 HTML 里的 <script src="katex/..."> 才能找到文件
            webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            context.coordinator.lastHtml = html
        }
        
        // 2. 滚动同步 (防抖动优化)
        DispatchQueue.main.async {
            // 只有当滚动变化超过一定阈值才执行，避免微小抖动
            if abs(context.coordinator.lastScroll - scrollPercentage) > 0.01 {
                let js = """
                var height = document.body.scrollHeight - window.innerHeight;
                window.scrollTo(0, height * \(scrollPercentage));
                """
                webView.evaluateJavaScript(js, completionHandler: nil)
                context.coordinator.lastScroll = scrollPercentage
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var lastHtml: String = ""
        var lastScroll: Double = 0.0
    }
}
