//
//  GhibliClient.swift
//  Ghibli App
//
//  Created by Antigravity on 2026/01/18.
//

import Foundation

/// 吉卜力API客户端，负责获取电影数据
struct GhibliClient {
    // 🚨 开发开关：设置为 true 则只读取本地数据，不访问网络
    static let useLocalData = true
    
    /// 获取电影数据
    /// - Returns: 电影数组
    /// - Throws: 网络错误或解析错误
    func fetchMovies() async throws -> [Movie] {
        // 1. 如果开启了本地模式，直接返回假数据
        if GhibliClient.useLocalData {
            // 模拟网络延迟，让你看清 Loading 动画
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            // 使用本地数据
            guard let data = LocalData.moviesJSON.data(using: .utf8) else {
                return []
            }
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            return movies
        }
        
        // 2. 正常的网络请求逻辑
        let urlString = "https://ghibliapi.vercel.app/films"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let movies = try JSONDecoder().decode([Movie].self, from: data)
        return movies
    }
}