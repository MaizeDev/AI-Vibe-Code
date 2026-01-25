import SwiftUI
#if os(iOS)
import UIKit
import Runestone
import TreeSitterMarkdown // 确保这个 import 成功

struct MarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.backgroundColor = .systemBackground
        
        // 1. 设置纯文本状态
        let state = TextViewState(text: text, theme: BasicTheme())
        textView.setState(state)
        
        // 2. 配置编辑器属性
        textView.showLineNumbers = true
        textView.lineHeightMultiplier = 1.3
        textView.dragInteractionEnabled = true
        
        // 3. 设置 Markdown 语法分析器
        setLanguage(for: textView)
        
        // 4. 设置代理 (用于监听文本变化)
        textView.editorDelegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: TextView, context: Context) {
        // 当 SwiftUI 的 text 变化时，如果编辑器里的内容不一样，才更新
        // (防止死循环: 输入->更新Binding->触发Update->重置光标)
        if uiView.text != text {
            let state = TextViewState(text: text, theme: BasicTheme())
            uiView.setState(state)
            // 重新设置语言，因为 setState 可能会重置它
            setLanguage(for: uiView)
        }
    }
    
    private func setLanguage(for textView: TextView) {
        // 这里加载 TreeSitterMarkdown 里的语言模型
        // 如果报错说找不到 TreeSitterLanguage，请检查 Package 依赖是否勾选了 TreeSitterMarkdown
        if let language = try? TreeSitterLanguage(tree_sitter_markdown()) {
             textView.setLanguageMode(TreeSitterLanguageMode(language: language))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TextViewDelegate {
        var parent: MarkdownEditor
        
        init(_ parent: MarkdownEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: TextView) {
            // 将编辑器的内容传回给 SwiftUI
            self.parent.text = textView.text
        }
    }
}
#else
// Mac 端占位符 (后面再处理)
struct MarkdownEditor: View {
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
    }
}
#endif