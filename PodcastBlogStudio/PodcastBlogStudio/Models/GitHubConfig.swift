//
//  GitHubConfig.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import Foundation

struct GitHubConfig: Codable, Equatable {
    var owner: String
    var repo: String
    var token: String
    var branch: String
    
    // --- 新增: 存储路径 ---
    var path: String // e.g., "source/_posts"
    
    // 修改默认值，适配你的 Hexo
    static let empty = GitHubConfig(owner: "", repo: "", token: "", branch: "main", path: "source/_posts")
    
    var isValid: Bool {
        return !owner.isEmpty && !repo.isEmpty && !token.isEmpty
    }
}
