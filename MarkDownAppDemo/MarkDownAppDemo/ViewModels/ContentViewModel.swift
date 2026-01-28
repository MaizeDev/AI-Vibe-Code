import SwiftUI
import Combine
import UniformTypeIdentifiers // 导出文件需要

// ViewModel 负责持有数据和处理业务逻辑
class ContentViewModel: ObservableObject {
    // --- 数据模型 ---
    @Published var markdownText: String = """
    # 重构测试
    
    现在业务逻辑已经分离到了 ViewModel 中。
    界面代码变得非常清爽。
    
    1. 输入不再卡顿
    2. 代码结构清晰
    """
    
    @Published var htmlContent: String = ""
    
    // --- 内部属性 ---
    private let engine = MarkdownBridge()
    private var cancellables = Set<AnyCancellable>()
    
    // 防抖输入流
    let textSubject = PassthroughSubject<String, Never>()
    
    // --- 初始化 ---
    init() {
        setupBindings()
        // 初始解析一次
        updateHtml(text: markdownText)
    }
    
    // --- 逻辑配置 ---
    private func setupBindings() {
        textSubject
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main) // 防抖 0.3s
            .removeDuplicates()
            .sink { [weak self] debouncedText in
                self?.updateHtml(text: debouncedText)
            }
            .store(in: &cancellables)
    }
    
    // 调用 C++ 核心
    private func updateHtml(text: String) {
        print("⚡️ ViewModel: Triggering C++ Parser...")
        let result = engine.parseMarkdown(text)
        self.htmlContent = result
    }
    
    // --- 公开方法：用户交互 ---
    
    // 1. 用户输入变化时调用
    func onTextChange(_ newValue: String) {
        // 发送给 Combine 管道去处理防抖
        textSubject.send(newValue)
    }
    
    // 2. 复制 HTML
    func copyHtmlToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(htmlContent, forType: .string)
        print("✅ HTML copied")
    }
    
    // 3. 导出文件
    func exportHtmlFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.html]
        savePanel.nameFieldStringValue = "Export.html"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try self.htmlContent.write(to: url, atomically: true, encoding: .utf8)
                    print("✅ Saved to: \(url.path)")
                } catch {
                    print("❌ Save failed: \(error)")
                }
            }
        }
    }
    
    // 4. 清空
    func clearText() {
        markdownText = ""
        onTextChange("") // 立即触发更新
    }
}