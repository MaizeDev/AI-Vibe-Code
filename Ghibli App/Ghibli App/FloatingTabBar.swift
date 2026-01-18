//
//  FloatingTabBar.swift
//  Ghibli App
//
//  Created by Antigravity on 2026/01/18.
//

import SwiftUI

/// 自定义浮动标签栏，采用分岛式设计
struct FloatingTabBar: View {
    /// 当前选中的标签页绑定
    @Binding var selectedTab: AppTab
    /// 用于标签切换动画的命名空间
    @Namespace private var animation
    
    // 定义左侧的主导航组
    private let mainTabs: [AppTab] = [.movies, .favorites, .settings]
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - 左侧：核心导航岛 (Main Navigation Island)
            HStack(spacing: 0) {
                ForEach(mainTabs) { tab in
                    Button {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0.2)) {
                            selectedTab = tab
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        ZStack {
                            // 选中态背景 (滑动的胶囊)
                            if selectedTab == tab {
                                Capsule()
                                    .fill(Color.primary)
                                    .matchedGeometryEffect(id: "ActiveTab", in: animation)
                                    .padding(4)
                            }
                            
                            // 图标
                            Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(selectedTab == tab ? Color(uiColor: .systemBackground) : .primary)
                                .scaleEffect(selectedTab == tab ? 1.0 : 0.9)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.regularMaterial) // regular 比 ultraThin 稍微厚一点点，质感更好，或者试用 .thinMaterial
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8) // 加深一点阴影，增加悬浮感
            
            // MARK: - 右侧：搜索孤岛 (Search Island)
            Button {
                withAnimation(.snappy) {
                    selectedTab = .search
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        // 修复点：两边都必须包裹在 AnyShapeStyle 中
                        .fill(selectedTab == .search ? AnyShapeStyle(Color.primary) : AnyShapeStyle(.ultraThinMaterial))
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .semibold))
                        // 选中时图标变反色，未选中时为原色
                        .foregroundStyle(selectedTab == .search ? Color(uiColor: .systemBackground) : .primary)
                }
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}