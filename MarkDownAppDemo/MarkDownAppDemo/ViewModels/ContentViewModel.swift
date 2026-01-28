import SwiftUI
import Combine
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
    @Published var markdownText: String = """
    # 离线公式与错误高亮测试
    
    ## 1. 正常公式 (离线加载)
    如果你的 `katex` 文件夹引用正确，下面应该能显示：
    $$
    f(x) = \\int_{-\\infty}^\\infty \\hat f(\\xi)\\,e^{2\\pi i \\xi x} \\,d\\xi
    $$
    
    ## 2. 错误高亮 (Typora 风格)
    随便写一个错误的 LaTeX 指令，比如 `\\badcommand`：
    
    $$
    E = mc^2 + \\badcommand
    $$
    
    你应该看到上面的公式显示为 **红色文字**，提示错误，而不是乱码或消失。
    """
    
    @Published var htmlContent: String = ""
    @Published var scrollPercentage: Double = 0.0
    
    private let engine = MarkdownBridge()
    private var cancellables = Set<AnyCancellable>()
    let textSubject = PassthroughSubject<String, Never>()
    
    init() {
        setupBindings()
        updateHtml(text: markdownText)
    }
    
    private func setupBindings() {
        textSubject
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] debouncedText in
                self?.updateHtml(text: debouncedText)
            }
            .store(in: &cancellables)
    }
    
    private func updateHtml(text: String) {
        let bodyFragment = engine.parseMarkdown(text)
        self.htmlContent = wrapHtmlTemplate(content: bodyFragment)
    }
    
    // --- 核心：离线 HTML 模版 ---
    private func wrapHtmlTemplate(content: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="zh">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          
          <!-- 1. 引用本地 KaTeX CSS (注意路径是相对的) -->
          <link rel="stylesheet" href="katex/katex.min.css">
          
          <!-- 2. 引用本地 KaTeX JS -->
          <script src="katex/katex.min.js"></script>
          <script src="katex/contrib/auto-render.min.js"></script>

          <style>
            :root {
                --bg: #ffffff; --text: #24292f; --border: #d0d7de;
                --code-bg: #f6f8fa; --pre-bg: #f6f8fa;
                --link: #0969da; --h-border: #d0d7de;
                /* 错误颜色定义 */
                --error-color: #cc0000;
            }
            @media (prefers-color-scheme: dark) {
                :root {
                    --bg: #0d1117; --text: #c9d1d9; --border: #30363d;
                    --code-bg: rgba(110,118,129,0.4); --pre-bg: #161b22;
                    --link: #58a6ff; --h-border: #21262d;
                    --error-color: #ff6b6b;
                }
            }
            body {
                font-family: -apple-system, sans-serif;
                font-size: 16px; line-height: 1.6; padding: 20px;
                color: var(--text); background-color: var(--bg);
            }
            /* ... (保持之前的常规样式) ... */
            h1, h2, h3 { border-bottom: 1px solid var(--h-border); padding-bottom: 0.3em; margin-top: 24px; }
            pre { background: var(--pre-bg); border: 1px solid var(--border); border-radius: 6px; padding: 16px; overflow: auto; }
            code { font-family: monospace; font-size: 85%; background: var(--code-bg); padding: 0.2em 0.4em; border-radius: 6px; }
            pre code { background: transparent; padding: 0; font-size: 100%; color: inherit; }
            img { max-width: 100%; }
            a { color: var(--link); text-decoration: none; }
            
            /* 3. ✅ Typora 风格错误高亮 */
            .katex-error {
                color: var(--error-color);
                font-weight: bold;
                border-bottom: 2px dotted var(--error-color);
            }
          </style>
        </head>
        <body>
          \(content)
          
          <!-- 4. 执行渲染脚本 (本地加载很快，直接执行即可) -->
          <script>
            document.addEventListener("DOMContentLoaded", function() {
                renderMathInElement(document.body, {
                    delimiters: [
                        {left: '$$', right: '$$', display: true},
                        {left: '$', right: '$', display: false}
                    ],
                    // 关键：设置为 false，这样 KaTeX 遇到错误不会抛出异常停止，
                    // 而是会生成一个带 .katex-error 类的元素，显示原始内容
                    throwOnError: false, 
                    errorColor: "#cc0000" // 默认错误色
                });
            });
          </script>
        </body>
        </html>
        """
    }
    
    // 工具函数保持不变...
    func onTextChange(_ newValue: String) { textSubject.send(newValue) }
    func clearText() { markdownText = ""; onTextChange("") }
    func copyHtmlToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(htmlContent, forType: .string)
    }
    func exportHtmlFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.html]
        savePanel.nameFieldStringValue = "Export.html"
        savePanel.canCreateDirectories = true
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                 try? self.htmlContent.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
