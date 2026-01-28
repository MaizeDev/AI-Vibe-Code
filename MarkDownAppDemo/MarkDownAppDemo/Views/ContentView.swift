import SwiftUI
import WebKit
import Combine // 1. 引入 Combine 框架用于处理防抖
import UniformTypeIdentifiers

struct ContentView: View {
    private let engine = MarkdownBridge()
    
    // 输入的 Markdown
    @State private var markdownText: String = """
    # 性能测试
    
    试着快速输入一些文字，你会发现 Preview 不会每敲一个字就闪烁一次，而是当你停顿时才更新。
    
    ## 工具栏测试
    点击右上角的按钮，可以复制生成的 HTML 代码。
    
    ```cpp
    // C++ Core is ready
    int main() { return 0; }
    ```
    """
    
    // 输出的 HTML
    @State private var htmlContent: String = ""
    
    // 2. 用于防抖的 Publisher
    // 我们创建一个 Subject 来接收用户的输入流
    let textSubject = PassthroughSubject<String, Never>()
    
    var body: some View {
        HSplitView {
            // --- 左侧：编辑器 ---
            VStack(alignment: .leading, spacing: 0) {
                // 顶部状态栏
                HStack {
                    Text("Markdown Editor")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .windowBackgroundColor))
                
                Divider()
                
                MacEditorView(text: $markdownText)
                    // 3. 关键修改：不再直接调用 updatePreview
                    // 而是发送给 Subject，让 Combine 去处理延时
                    .onChange(of: markdownText) { _, newValue in
                        textSubject.send(newValue)
                    }
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .textBackgroundColor))
            
            // --- 右侧：预览 ---
            VStack(alignment: .leading, spacing: 0) {
                // 顶部工具栏
                HStack {
                    Text("Preview")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // --- 工具栏按钮：复制 HTML ---
                    Button(action: copyHtmlToClipboard) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .help("Copy HTML to Clipboard") // 鼠标悬停提示
                    .buttonStyle(.borderless)
                    .padding(.trailing, 8)
                    
                    // --- 工具栏按钮：导出文件 ---
                    Button(action: exportHtmlFile) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                    }
                    .help("Export HTML File")
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .windowBackgroundColor))
                
                Divider()
                
                WebView(html: htmlContent)
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
        }
        // 4. 处理防抖逻辑
        .onReceive(
            textSubject
                .debounce(for: .seconds(0.3), scheduler: RunLoop.main) // 停顿 0.3 秒才执行
                .removeDuplicates() // 如果内容没变就不执行
        ) { debouncedText in
            // 这里才是真正调用 C++ 的地方
            updatePreview(text: debouncedText)
        }
        .onAppear {
            // 初始化
            updatePreview(text: markdownText)
        }
        // 5. 整个窗口的工具栏 (可选，macOS 风格)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { markdownText = "" }) {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
    }
    
    // 调用 C++ 核心
    func updatePreview(text: String) {
        print("⚡️ Triggering C++ Parser...") // 调试日志：观察触发频率
        self.htmlContent = engine.parseMarkdown(text)
    }
    
    // 功能：复制 HTML
    func copyHtmlToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(htmlContent, forType: .string)
        print("✅ HTML copied to clipboard")
    }
    
    // 功能：导出文件 (调用系统保存面板)
    func exportHtmlFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.html]
        savePanel.nameFieldStringValue = "Export.html"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try htmlContent.write(to: url, atomically: true, encoding: .utf8)
                    print("✅ File saved to: \(url.path)")
                } catch {
                    print("❌ Save failed: \(error)")
                }
            }
        }
    }
}

// WebView 保持不变
struct WebView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        if !html.isEmpty {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}

#Preview {
    ContentView()
}
