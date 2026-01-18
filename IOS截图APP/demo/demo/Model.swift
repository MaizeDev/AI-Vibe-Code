import SwiftUI

/// 卡片的主题样式模型（原逻辑保留）
struct CardTheme: Identifiable, Sendable, Hashable {
    let id = UUID()
    let name: String
    let background: AnyShapeStyle
    let textColor: Color
    let fontName: String

    static func == (lhs: CardTheme, rhs: CardTheme) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 预设主题（原数据不动）
extension CardTheme {
    static let allThemes: [CardTheme] = [
        CardTheme(
            name: "极简白",
            background: AnyShapeStyle(Color.white),
            textColor: .black,
            fontName: "PingFangSC-Regular"
        ),
        CardTheme(
            name: "深邃黑",
            background: AnyShapeStyle(Color.black),
            textColor: .white,
            fontName: "PingFangSC-Regular"
        ),
        CardTheme(
            name: "落日",
            background: AnyShapeStyle(
                LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            ),
            textColor: .white,
            fontName: "PingFangSC-Semibold"
        ),
        CardTheme(
            name: "海洋",
            background: AnyShapeStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.8), .cyan],
                    startPoint: .top,
                    endPoint: .bottom
                )
            ),
            textColor: .white,
            fontName: "PingFangSC-Medium"
        ),
        CardTheme(
            name: "森林",
            background: AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.2),
                        Color(red: 0.2, green: 0.5, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            ),
            textColor: Color(white: 0.9),
            fontName: "PingFangSC-Light"
        )
    ]
}
