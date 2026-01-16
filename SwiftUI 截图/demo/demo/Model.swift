//
//  Model.swift
//  demo
//
//  Created by wheat on 1/15/26.
//

import SwiftUI

/// 卡片的主题样式模型
struct CardTheme: Identifiable, Sendable, Hashable {
    let id = UUID()
    let name: String
    let background: AnyShapeStyle // 使用 AnyShapeStyle 以支持颜色和渐变
    let textColor: Color
    let fontName: String
    
    // 为了符合 Sendable 和 Hashable，我们需要自定义比较逻辑，
    // 但为了简化演示，这里我们使用静态预设，实际项目中可优化
    static func == (lhs: CardTheme, rhs: CardTheme) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// 预设主题数据
extension CardTheme {
    static let allThemes: [CardTheme] = [
        CardTheme(name: "极简白", background: AnyShapeStyle(Color.white), textColor: .black, fontName: "PingFangSC-Regular"),
        CardTheme(name: "深邃黑", background: AnyShapeStyle(Color.black), textColor: .white, fontName: "PingFangSC-Regular"),
        CardTheme(name: "落日", background: AnyShapeStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)), textColor: .white, fontName: "PingFangSC-Semibold"),
        CardTheme(name: "海洋", background: AnyShapeStyle(LinearGradient(colors: [Color.blue.opacity(0.8), Color.cyan], startPoint: .top, endPoint: .bottom)), textColor: .white, fontName: "PingFangSC-Medium"),
        CardTheme(name: "森林", background: AnyShapeStyle(LinearGradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.2), Color(red: 0.2, green: 0.5, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)), textColor: .init(white: 0.9), fontName: "PingFangSC-Light")
    ]
}
