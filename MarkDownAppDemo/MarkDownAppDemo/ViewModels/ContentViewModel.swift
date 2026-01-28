import SwiftUI
import Combine
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
    
    // 规范的 Markdown 测试模版
    @Published var markdownText: String = """
    # 终极重构版 Demo
    
    ## 1. 代码块 (带行号 & 高亮)
    右侧应该显示行号，左侧应该是橙色文字。
    
    ```swift
    import SwiftUI

    struct HelloView: View {
        var body: some View {
            Text("Hello World")
        }
    }
    ```
    
    ## 2. 表格 (Table)
    **注意**：表格上下要有空行，分割线至少三个短横线。
    
    | 库名       | 功能           | 状态 |
    | :---      | :---:         | ---: |
    | Down      | 解析 Markdown  | ✅   |
    | KaTeX     | 数学公式       | ✅   |
    | Highlight | 代码高亮       | ✅   |
    
    ## 3. 标题级别测试
    ### H3 标题
    #### H4 标题
    ##### H5 标题
    ###### H6 标题 (应该变小加粗)
    
    ## 4. 数学公式
    $$
    f(x) = \\int_{-\\infty}^\\infty \\hat f(\\xi)\\,e^{2\\pi i \\xi x} \\,d\\xi
    $$
    """
    
    @Published var htmlContent: String = ""
    @Published var scrollPercentage: Double = 0.0
    
    private let service = MarkdownService()
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
        let result = service.render(text)
        self.htmlContent = result
    }
    
    // --- 用户交互 ---
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
