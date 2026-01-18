//
//  ContentView.swift
//  Ghibli App
//
//  Created by Antigravity on 2026/01/18.
//

import SwiftUI
import SwiftData

/// 应用主内容视图，包含底部导航栏和内容区域
struct ContentView: View {
    /// 应用状态管理器，用于获取电影数据
    @State private var store = AppStore()
    /// 当前选中的标签页
    @State private var selectedTab: AppTab = .movies
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. 内容层 - 根据当前选中的标签页显示不同内容
            Group {
                switch selectedTab {
                case .movies:
                    MoviesFeedView()
                case .favorites:
                    FavoritesView()
                case .settings:
                    SettingsView()
                case .search:
                    SearchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 🔥 关键修改 1: 让内容延伸到屏幕最底部，这样导航栏才有东西可以"模糊"
            .ignoresSafeArea(edges: .bottom)
            
            // 2. 悬浮导航栏 (Split-Island Style)
            FloatingTabBar(selectedTab: $selectedTab)
                // 🔥 关键修改 2: 给导航栏底部加一点 padding，防止贴底太紧
                .padding(.bottom, 20)
        }
        .environment(store)  // 将AppStore实例传递到环境，供子视图使用
        // 设置整个 App 的背景色，防止深色模式下透出黑色
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}