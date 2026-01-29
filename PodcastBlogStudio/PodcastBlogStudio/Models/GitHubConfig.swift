//
//  GitHubConfig.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import Foundation

/// GitHub 仓库配置信息
struct GitHubConfig: Codable, Equatable {
    var owner: String       // GitHub 用户名 (e.g., "apple")
    var repo: String        // 仓库名 (e.g., "swift")
    var token: String       // Personal Access Token
    var branch: String      // 分支 (默认 main)
    
    static let empty = GitHubConfig(owner: "", repo: "", token: "", branch: "main")
    
    var isValid: Bool {
        return !owner.isEmpty && !repo.isEmpty && !token.isEmpty
    }
}