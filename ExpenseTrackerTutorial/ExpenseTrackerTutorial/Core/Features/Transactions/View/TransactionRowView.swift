//
//  TransactionRowView.swift
//  ExpenseTrackerTutorial
//
//  Created by wheat on 2/2/26.
//

import SwiftUI

// 定义一个 SwiftUI 视图 TransactionRowView，用于在列表中显示单笔交易。
struct TransactionRowView: View {
    let tx: AITransaction  // 存储要显示的交易数据。
    
    var body: some View {
        HStack {  // 水平排列视图。
            // 显示类别图标。
            Image(systemName: tx.category.iconInfo.symbol)
                .font(.headline)
                .foregroundColor(tx.category.iconInfo.color)
                .frame(width: 40, height: 40)
                .background(tx.category.iconInfo.color.opacity(0.1))
                .cornerRadius(10)
            
            // 垂直排列商户名称和类别名称。
            VStack(alignment: .leading, spacing: 4) {
                Text(tx.merchant)  // 显示商户名称。
                    .font(.headline)
                Text(tx.category.displayName)  // 显示类别名称。
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()  // 添加间隔，将金额推到右侧。
            
            VStack(alignment: .trailing, spacing: 4) {
                // 显示交易金额，格式化为两位小数。
                Text("$\(tx.amount, specifier: "%.2f")")
                    .font(.headline)
                Text(tx.date.formatted())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)  // 添加垂直内边距。
    }
}

// 为 TransactionRowView 提供预览。
#Preview {
    List {
        TransactionRowView(tx: AITransaction.moke)  // 在列表中显示一个模拟交易行。
    }
}
