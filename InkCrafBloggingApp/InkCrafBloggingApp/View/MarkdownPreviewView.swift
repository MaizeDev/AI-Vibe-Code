import SwiftUI
import WebKit
import Markdown // 引用 Apple 的 swift-markdown 库

struct MarkdownPreviewView: UIViewRepresentable {
    let content: String // Markdown 源码
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 1. 将 Markdown 解析为 HTML
        let htmlBody = renderMarkdownToHTML(markdown: content)
        
        // 2. 包装成完整的 HTML 页面 (注入 CSS)
        let fullHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, system-ui, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    padding: 20px;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                }
                @media (prefers-color-scheme: dark) {
                    body { color: #ddd; background-color: #000; }
                    a { color: #64D2FF; }
                    code { background-color: #333; border: 1px solid #444; }
                }
                h1, h2, h3 { margin-top: 1.5em; margin-bottom: 0.5em; font-weight: bold; }
                h1 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                p { margin-bottom: 1em; }
                code {
                    font-family: Menlo, monospace;
                    background-color: #f4f4f4;
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-size: 0.9em;
                }
                pre {
                    background-color: #f6f8fa;
                    padding: 16px;
                    overflow: auto;
                    border-radius: 8px;
                }
                pre code { background-color: transparent; border: none; }
                img { max-width: 100%; border-radius: 6px; }
                blockquote {
                    border-left: 4px solid #dfe2e5;
                    color: #6a737d;
                    padding-left: 1em;
                    margin: 0;
                }
            </style>
        </head>
        <body>
            \(htmlBody)
        </body>
        </html>
        """
        
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }
    
    // 简单的解析器：利用 Apple swift-markdown 把 AST 转 HTML
    // 注意：swift-markdown 本身只生成树，不直接生成 HTML 字符串
    // 这里为了演示方便，我们写一个极其简易的转换，或者暂时只做基础转换
    // *实际生产中通常会用 Down 或 Ink 库，但我们尽量少引入依赖*
    private func renderMarkdownToHTML(markdown: String) -> String {
        // 解析 Markdown 文档
        let document = Document(parsing: markdown)
        
        // 自定义访问者将 AST 转 HTML (为了代码简洁，这里用一个极简方案)
        // 如果你觉得太麻烦，我们可以先只显示 raw 文本，或者引入 Ink 库
        // 这里为了不引入新库，我们写个超简单的替换逻辑（仅作 MVP 演示）
        // *正式版建议引入 Ink 库*
        
        var html = markdown
            .replacingOccurrences(of: "\n", with: "<br>")
        
        // ⚠️ 真正的 Markdown 转 HTML 需要遍历 document.walker()
        // 既然我们引入了 swift-markdown，我们应该利用它。
        // 由于 swift-markdown 官方没有直接的 .toHTML() 方法，
        // 为了不卡在造轮子上，我建议我们在这个阶段：
        // **临时引入一个微型库 'Ink' (由 John Sundell 开发)**
        // 它是纯 Swift 的，非常轻量。
        
        return "<h3>暂用简易预览</h3><p>为了完美预览，建议引入 Ink 库。</p><hr>" + html
    }
}