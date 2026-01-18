//
//  AppTab.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//

import SwiftUI

/// 应用标签枚举，定义了底部导航栏的所有标签页
enum AppTab: String, CaseIterable, Identifiable {
    /// 电影列表标签页
    case movies = "Movies"
    /// 收藏标签页
    case favorites = "Favorites"
    /// 搜索标签页
    case search = "Search"
    /// 设置标签页
    case settings = "Settings"
    
    /// 实现Identifiable协议的id属性
    var id: String { rawValue }
    
    /// 默认图标系统名称
    var icon: String {
        switch self {
        case .movies: return "film.stack"
        case .favorites: return "heart"
        case .search: return "magnifyingglass"
        case .settings: return "gearshape"
        }
    }
    
    /// 选中状态下图标系统名称
    var selectedIcon: String {
        switch self {
        case .movies: return "film.stack.fill"
        case .favorites: return "heart.fill"
        case .search: return "text.magnifyingglass"
        case .settings: return "gearshape.fill"
        }
    }
}