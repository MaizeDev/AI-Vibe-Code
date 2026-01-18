//
//  Ghibli_AppApp.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//

//
//  Ghibli_AppApp.swift
//  Ghibli App
//
//  Created by Antigravity on 2026/01/18.
//

import SwiftData
import SwiftUI

/// 应用程序入口点，配置SwiftData容器和主窗口
@main
struct Ghibli_AppApp: App {
    /// SwiftData模型容器，用于管理FavoriteMovie数据
    let container: ModelContainer

    /// 初始化应用程序并创建SwiftData容器
    init() {
        do {
            // 创建模型容器，用于存储收藏的电影数据
            container = try ModelContainer(for: FavoriteMovie.self)
        } catch {
            // 如果初始化失败，终止应用程序
            fatalError("Failed to init SwiftData: \(error)")
        }
    }

    /// 应用程序主体，定义窗口和场景
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)  // 将SwiftData容器附加到场景
    }
}