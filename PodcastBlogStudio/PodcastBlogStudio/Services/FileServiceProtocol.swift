//
//  ServiceProtocols.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import Foundation

// MARK: - File Service Protocol
protocol FileServiceProtocol {
    func save(post: Post) async throws
    func loadAllPosts() async throws -> [Post]
    func delete(post: Post) async throws
    
    // 之前报错是因为缺了下面这一行声明：
    func rename(oldFileName: String, newFileName: String) async throws
}

// MARK: - GitHub Service Protocol
protocol GitHubServiceProtocol {
    func publish(post: Post, config: GitHubConfig) async throws -> String
    func delete(post: Post, config: GitHubConfig) async throws
}

// MARK: - Settings Service Protocol
// 之前报错是因为缺了整个协议定义：
protocol SettingsServiceProtocol {
    func load() -> GitHubConfig
    func save(_ config: GitHubConfig)
}
