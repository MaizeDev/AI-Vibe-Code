import SwiftUI
import AppKit

struct MacEditorView: NSViewRepresentable {
    @Binding var text: String
    @Binding var scrollPercentage: Double // 确保 ViewModel 里有这个

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
        // 基础字体使用等宽，保证排版整齐
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.insertionPointColor = NSColor.controlAccentColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.drawsBackground = true
        
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.allowsUndo = true
        textView.autoresizingMask = [.width, .height]
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        // 关键：语法高亮代理
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
        
        // --- 核心：语法高亮 ---
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard editedMask.contains(.editedCharacters) else { return }
            
            let string = textStorage.string
            let wholeRange = NSRange(location: 0, length: textStorage.length)
            
            // 1. 重置基础样式
            textStorage.removeAttribute(.foregroundColor, range: wholeRange)
            textStorage.removeAttribute(.font, range: wholeRange)
            
            // 默认样式
            let defaultFont = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
            textStorage.addAttribute(.font, value: defaultFont, range: wholeRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: wholeRange)
            
            do {
                // A. 标题 (H1 - H6) - 蓝色加粗
                // 正则说明：^ 表示行首，#{1,6} 表示1到6个井号，\\s 表示空格
                let headerRegex = try NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: .anchorsMatchLines)
                headerRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: matchRange)
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), range: matchRange)
                    }
                }
                
                // B. 代码块 (```...```) - 优化配色
                // 整个代码块变色，不仅是标记
                let codeBlockRegex = try NSRegularExpression(pattern: "```[\\s\\S]*?```", options: [])
                codeBlockRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        // 使用 systemBrown 或 systemOrange 让代码块明显（类似 sublime/vscode 的字符串颜色）
                        // 在深色模式下，systemOrange 通常很清晰
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: matchRange)
                    }
                }
                
                // C. 行内代码 (`...`) - 红色
                let inlineCodeRegex = try NSRegularExpression(pattern: "`[^`\\n]+`", options: [])
                inlineCodeRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemRed, range: matchRange)
                    }
                }
                
                // D. 数学公式 ($$) - 紫色
                let mathRegex = try NSRegularExpression(pattern: "\\$\\$[\\s\\S]*?\\$\\$", options: [])
                mathRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: matchRange)
                    }
                }
                
                // E. 链接 ([text](url)) - 灰色弱化
                let linkRegex = try NSRegularExpression(pattern: "\\[(.*?)\\]\\((.*?)\\)", options: [])
                linkRegex.enumerateMatches(in: string, options: [], range: wholeRange) { match, _, _ in
                    if let matchRange = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: matchRange)
                        textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: matchRange)
                    }
                }
                
            } catch {
                print("Regex Error: \(error)")
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
