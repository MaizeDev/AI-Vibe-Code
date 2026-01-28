import SwiftUI
import AppKit

struct MacEditorView: NSViewRepresentable {
    @Binding var text: String
    @Binding var scrollPercentage: Double

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor.textBackgroundColor
        
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )
        
        let textView = NSTextView()
        textView.isRichText = false
        // 使用 SF Mono 或 Menlo，这对对齐公式非常重要
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = NSColor.labelColor
        // 光标颜色设为醒目的颜色
        textView.insertionPointColor = NSColor.systemPurple
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.drawsBackground = true
        
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.allowsUndo = true
        textView.autoresizingMask = [.width, .height]
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        textView.textStorage?.delegate = context.coordinator
        textView.delegate = context.coordinator
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            if let range = selectedRanges.first as? NSRange, range.location <= text.count {
                textView.selectedRanges = selectedRanges
            }
        }
    }
    
    static func dismantleNSView(_ nsView: NSScrollView, coordinator: Coordinator) {
        NotificationCenter.default.removeObserver(coordinator)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
        var parent: MacEditorView
        
        init(_ parent: MacEditorView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
        
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard editedMask.contains(.editedCharacters) else { return }
            
            let string = textStorage.string
            let wholeRange = NSRange(location: 0, length: textStorage.length)
            
            // 重置样式
            textStorage.removeAttribute(.foregroundColor, range: wholeRange)
            // 默认字体
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: wholeRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: wholeRange)
            
            do {
                // 1. 标题 (蓝色 + 加粗)
                let headerRegex = try NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: .anchorsMatchLines)
                headerRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: matchRange)
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), range: matchRange)
                    }
                }
                
                // 2. 代码块 (弱化灰色)
                let codeBlockRegex = try NSRegularExpression(pattern: "```[\\s\\S]*?```", options: [])
                codeBlockRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: matchRange)
                    }
                }
                
                // 3. ✅ 公式光标优化 (数学公式专用高亮)
                // 块级公式 $$ ... $$
                let mathBlockRegex = try NSRegularExpression(pattern: "\\$\\$[\\s\\S]*?\\$\\$", options: [])
                mathBlockRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        // 使用紫色，明显区分于普通文本
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: matchRange)
                        // 稍微调大一点字体，方便看清上标下标
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15.5, weight: .medium), range: matchRange)
                    }
                }
                
                // 4. ✅ 行内公式优化 $ ... $
                // 正则解释：匹配 $ 开头，非换行非$的内容，以 $ 结尾
                let inlineMathRegex = try NSRegularExpression(pattern: "(?<!\\\\)\\$[^\\$\\n]+\\$", options: [])
                inlineMathRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        // 行内公式也用紫色
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: matchRange)
                    }
                }
                
            } catch {
                print("Highlight Error: \(error)")
            }
        }
        
        @objc func scrollViewDidScroll(_ notification: Notification) {
            guard let contentView = notification.object as? NSClipView,
                  let scrollView = contentView.superview as? NSScrollView,
                  let documentView = scrollView.documentView else { return }
            
            let visibleRect = contentView.documentVisibleRect
            let contentHeight = documentView.bounds.height
            let visibleHeight = visibleRect.height
            
            if contentHeight > visibleHeight {
                let percentage = visibleRect.origin.y / (contentHeight - visibleHeight)
                DispatchQueue.main.async {
                    self.parent.scrollPercentage = max(0.0, min(1.0, percentage))
                }
            }
        }
    }
}
