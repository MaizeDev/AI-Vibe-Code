//
//  InfoBadge.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI

/// 信息徽章组件，用于展示带有图标的小型信息标签
struct InfoBadge: View {
    /// 徽章图标系统名称
    let icon: String
    /// 徽章文本内容
    let text: String
    /// 徽章文字颜色，默认为primary
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }
}