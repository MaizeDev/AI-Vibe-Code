import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        // 配置 WebView，使其更符合原生体验
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        // 设为透明背景，由外部 SwiftUI 容器控制底色
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 只有内容不为空时才加载，避免闪烁
        if !html.isEmpty {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}