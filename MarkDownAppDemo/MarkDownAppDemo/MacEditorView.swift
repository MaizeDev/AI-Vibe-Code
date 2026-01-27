import SwiftUI
import AppKit

// 这是一个原生的 macOS 文本编辑器组件
struct MacEditorView: NSViewRepresentable {
    @Binding var text: String
    var onTextChange: ((String) -> Void)?

    func makeNSView(context: Context) -> NSScrollView {
        // 1. 创建 ScrollView (macOS 的文本框必须包在 ScrollView 里)
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        
        // 2. 创建 NSTextView (强大的核心)
        let textView = NSTextView()
        textView.isRichText = false // 纯文本模式
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.allowsUndo = true // 开启撤销/重做
        textView.isAutomaticQuoteSubstitutionEnabled = false // 禁止自动把引号变弯
        
        // 设置宽高自动调整
        textView.autoresizingMask = [.width, .height]
        
        // 3. 绑定 Delegate
        textView.delegate = context.coordinator
        
        // 4. 组装
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // 数据单向流动：SwiftUI -> AppKit
        // 注意：这里需要防死循环判断，只有文本真的变了才赋值
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 协调器：处理 AppKit 的回调
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditorView

        init(_ parent: MacEditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // 数据回流：AppKit -> SwiftUI
            parent.text = textView.string
            parent.onTextChange?(textView.string)
        }
    }
}