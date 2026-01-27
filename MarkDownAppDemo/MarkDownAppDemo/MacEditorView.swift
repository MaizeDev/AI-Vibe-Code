import SwiftUI
import AppKit

struct MacEditorView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor.textBackgroundColor
        
        let textView = NSTextView()
        textView.isRichText = false // 虽然是纯文本模式，但我们可以用 Attributed String 渲染颜色
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.insertionPointColor = NSColor.controlAccentColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.drawsBackground = true
        
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.allowsUndo = true
        textView.autoresizingMask = [.width, .height]
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        // 关键：接管 textStorage 的代理，负责处理高亮
        textView.textStorage?.delegate = context.coordinator
        textView.delegate = context.coordinator
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // 避免光标跳动：只有当文本内容真的完全不同且不是由用户输入触发时才全量更新
        if textView.string != text {
            // 保存光标位置
            let selectedRanges = textView.selectedRanges
            textView.string = text
            // 恢复光标位置（如果还在范围内）
            if let range = selectedRanges.first as? NSRange, range.location <= text.count {
                textView.selectedRanges = selectedRanges
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
        var parent: MacEditorView
        
        init(_ parent: MacEditorView) {
            self.parent = parent
        }
        
        // --- 1. 处理文本变化 (双向绑定) ---
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
        
        // --- 2. 核心：处理语法高亮 ---
        // 每次文本发生变化时，系统都会调用这个方法，让我们有机会修改文字的颜色/字体
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            
            // 只有当字符发生改变时才处理
            guard editedMask.contains(.editedCharacters) else { return }
            
            let wholeRange = NSRange(location: 0, length: textStorage.length)
            let string = textStorage.string
            
            // 1. 重置基础样式 (防止颜色残留)
            textStorage.removeAttribute(.foregroundColor, range: wholeRange)
            textStorage.removeAttribute(.font, range: wholeRange)
            
            // 设置默认字体颜色
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: wholeRange)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: wholeRange)
            
            // 2. 开始正则匹配高亮
            // 注意：为了性能，这里只演示简单的正则。如果是百万行代码，需要只处理 editedRange 附近的段落。
            
            do {
                // --- A. 标题 (# Header) ---
                // 匹配行首的 #, ##, ### ...
                let headerRegex = try NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: .anchorsMatchLines)
                headerRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        // 标题设为蓝色
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: matchRange)
                        // 标题字体变大加粗
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 18, weight: .bold), range: matchRange)
                    }
                }
                
                // --- B. 加粗 (**Bold**) ---
                let boldRegex = try NSRegularExpression(pattern: "\\*\\*.*?\\*\\*", options: [])
                boldRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: matchRange)
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .bold), range: matchRange)
                    }
                }
                
                // --- C. 代码块 (```Code```) ---
                // 这是一个简单的多行匹配
                let codeBlockRegex = try NSRegularExpression(pattern: "```[\\s\\S]*?```", options: [])
                codeBlockRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        // 代码块颜色变灰
                        textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: matchRange)
                    }
                }
                
                // --- D. 引用 (> Quote) ---
                let quoteRegex = try NSRegularExpression(pattern: "^>.*$", options: .anchorsMatchLines)
                quoteRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: matchRange)
                    }
                }
                
            } catch {
                print("Highlight regex error: \(error)")
            }
        }
    }
}
