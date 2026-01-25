import SwiftUI
#if os(iOS)
import UIKit
import Runestone
import TreeSitterMarkdown

struct MarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.backgroundColor = .systemBackground
        
        // 1. 设置纯文本状态
        // 注意：现在 BasicTheme 已经修复，符合 Theme 协议
        let state = TextViewState(text: text, theme: BasicTheme())
        textView.setState(state)
        
        // 2. 配置编辑器属性
        textView.showLineNumbers = true
        textView.lineHeightMultiplier = 1.3
        // textView.dragInteractionEnabled = true // 删除这行，Runestone 不支持
        
        // 3. 设置 Markdown 语法分析器
        setLanguage(for: textView)
        
        // 4. 设置代理
        textView.editorDelegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: TextView, context: Context) {
        if uiView.text != text {
            let state = TextViewState(text: text, theme: BasicTheme())
            uiView.setState(state)
            setLanguage(for: uiView)
        }
    }
    
    private func setLanguage(for textView: TextView) {
        // 修复：直接初始化，不需要 try，也不需要 try?
        let language = TreeSitterLanguage(tree_sitter_markdown())
        textView.setLanguageMode(TreeSitterLanguageMode(language: language))
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
            self.parent.text = textView.text
        }
    }
}
#else
// Mac 端占位符
struct MarkdownEditor: View {
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
    }
}
#endif
