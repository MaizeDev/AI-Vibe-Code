import UIKit
import Runestone

// 🔴 修复点：将 struct 改为 final class
final class BasicTheme: Runestone.Theme {
    var font: UIFont = .monospacedSystemFont(ofSize: 15, weight: .regular)
    var textColor: UIColor = .label
    
    var gutterBackgroundColor: UIColor = .secondarySystemBackground
    var gutterHairlineColor: UIColor = .separator
    
    var lineNumberColor: UIColor = .secondaryLabel
    var lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 13, weight: .regular)
    
    var selectedLineBackgroundColor: UIColor = .secondarySystemBackground.withAlphaComponent(0.5)
    var selectedLinesLineNumberColor: UIColor = .label
    var selectedLinesGutterBackgroundColor: UIColor = .clear
    
    var invisibleCharactersColor: UIColor = .tertiaryLabel
    
    var pageGuideHairlineColor: UIColor = .separator
    var pageGuideBackgroundColor: UIColor = .secondarySystemBackground
    
    var markedTextBackgroundColor: UIColor = .systemFill
    var markedTextBackgroundCornerRadius: CGFloat = 4
    
    // 初始化器 (类需要显式初始化，虽然属性都有默认值，但为了保险加一个空的 init)
    init() {}
    
    // --- 语法高亮配置 ---
    
    func textColor(for highlightName: String) -> UIColor? {
        switch highlightName {
        case "markup.heading", "markup.heading.1", "markup.heading.2", "markup.heading.3", "markup.heading.4", "markup.heading.5", "markup.heading.6":
            return .systemBlue
        case "markup.bold", "markup.italic":
            return .label
        case "markup.link", "markup.link.url", "string.url", "markup.link.text":
            return .systemRed
        case "markup.list", "markup.list.unchecked", "markup.list.checked":
            return .systemOrange
        case "comment":
            return .systemGray
        case "code", "markup.raw.inline", "markup.raw.block":
            return .secondaryLabel
        default:
            return nil
        }
    }
    
    func fontTraits(for highlightName: String) -> UIFontDescriptor.SymbolicTraits {
        if highlightName.contains("markup.bold") || highlightName.contains("markup.heading") {
            return .traitBold
        }
        if highlightName.contains("markup.italic") {
            return .traitItalic
        }
        return []
    }
    
    func shadow(for highlightName: String) -> NSShadow? {
        return nil
    }
}
