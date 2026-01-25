//
//  CollapsibleText.swift
//  notes
//
//  Created by wheat on 1/23/26.
//

import SwiftUI
import UIKit // 需要引入 UIKit 来使用 UILabel 进行计算

struct CollapsibleText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded = false
    @State private var isTruncated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // 文本主体
            Text(text)
                .font(.body) // 明确指定字体，以便计算
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // 使用 GeometryReader 获取当前 Text 组件的实际渲染宽度
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                // 视图出现时计算
                                checkTruncation(width: geo.size.width)
                            }
                            .onChange(of: geo.size.width) { _, newWidth in
                                // 宽度变化时（如旋转屏幕）重新计算
                                checkTruncation(width: newWidth)
                            }
                    }
                )

            // 显示更多按钮
            if isTruncated && !isExpanded {
                Button("显示更多") {
                    withAnimation(.easeInOut) {
                        isExpanded = true
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
                .buttonStyle(.plain) // 防止在 List 中点击穿透
            }
        }
    }

    // 核心计算逻辑
    private func checkTruncation(width: CGFloat) {
        let label = UILabel()
        label.text = text
        // ⚠️ 关键：这里必须和 SwiftUI Text 使用的字体完全一致
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        // 1. 计算完整显示所需的高度
        label.numberOfLines = 0
        let totalSize = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        // 2. 计算限制行数后的高度
        label.numberOfLines = lineLimit
        let limitedSize = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        // 3. 比较高度 (加 1.0 容差处理浮点数精度问题)
        isTruncated = totalSize.height > (limitedSize.height + 1.0)
    }
}
