import UIKit
import Runestone

struct BasicTheme: EditorTheme {
    var backgroundColor: UIColor = .systemBackground
    var userInterfaceStyle: UIUserInterfaceStyle = .dark
    
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
    
    // --- 语法高亮配置 ---
    // 这里只配置了最基础的：关键字(比如#)变蓝，字符串变红
    func textColor(for highlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(highlightName) else { return nil }
        switch highlightName {
        case .keyword, .markupHeadings: // # 标题
            return .systemBlue
        case .string, .markupLinkUrl: // 链接 URL
            return .systemRed
        case .comment:
            return .systemGray
        case .markupBold, .markupItalic:
            return .label
        default:
            return .label
        }
    }
    
    func fontTraits(for highlightName: String) -> UIFontDescriptor.SymbolicTraits {
        guard let highlightName = HighlightName(highlightName) else { return [] }
        if highlightName == .markupBold || highlightName == .markupHeadings {
            return .traitBold
        }
        if highlightName == .markupItalic {
            return .traitItalic
        }
        return []
    }
}