//
//  AppStore.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//

import Observation
import Foundation

/// 应用状态管理器，负责获取和管理电影数据
@Observable
@MainActor
class AppStore {
    /// 存储电影列表
    var movies: [Movie] = []
    /// 指示是否正在加载数据
    var isLoading: Bool = false
    /// 存储错误消息
    var errorMessage: String?

    /// 吉卜力API客户端
    private let client = GhibliClient()

    /// 异步加载电影数据
    func loadMovies() async {
        // 避免重复加载
        guard movies.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedMovies = try await client.fetchMovies()
            // 按发布时间倒序排列
            movies = fetchedMovies.sorted { $0.releaseDate > $1.releaseDate }
        } catch {
            errorMessage = "Connection Lost: \(error.localizedDescription)"
        }
    }
}