//
//  TransactionsView.swift
//  ExpenseTrackerTutorial
//
//  Created by wheat on 2/2/26.
//

import SwiftUI

// 定义一个 SwiftUI 视图 TransactionsView，用于显示交易列表。
struct TransactionsView: View {
    @State private var transactions: [AITransaction] = []  // 使用 @State 属性包装器来管理交易数组，并用模拟数据初始化。
    @State private var showingAdd: Bool = false  // 控制添加交易工作表的显示。

    var body: some View {
        NavigationStack {  // 包装在 NavigationStack 中以支持导航功能。
            Group {  // 使用 Group 来组织条件视图。
                if transactions.isEmpty {
                    // 如果没有交易，显示一个内容不可用视图。
                    ContentUnavailableView(
                        "没有交易",
                        systemImage: "tray",
                        description: Text("从添加第一笔交易开始。"))
                } else {
                    // 如果有交易，使用 List 显示它们。
                    List {
                        ForEach(transactions) { tx in
                            TransactionRowView(tx: tx)  // 为每笔交易创建一个 TransactionRowView。
                        }
                    }
                }
            }
            .navigationTitle("交易")  // 设置导航栏标题。
            .sheet(isPresented: $showingAdd, content: {
                Text("在这里添加交易")  // 当 showingAdd 为 true 时显示一个工作表。
            })
            .toolbar {
                // 在导航栏左侧添加一个编辑按钮。
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                // 在导航栏右侧添加一个加号按钮，用于添加新交易。
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                // 在视图显示时加载模拟数据。
                loadSamples()
            }
        }
    }
}

// 定义一个私有扩展，用于加载模拟数据。
private extension TransactionsView {
    func loadSamples() {
        self.transactions = AITransaction.moks
    }
}

// 为 TransactionsView 提供预览。
#Preview {
    TransactionsView()
}
