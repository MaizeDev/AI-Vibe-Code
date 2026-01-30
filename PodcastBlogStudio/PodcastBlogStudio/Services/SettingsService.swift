//
//  SettingsService.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import Foundation

final class SettingsService: SettingsServiceProtocol {
    private let key = "GitHubConfig"
    
    func save(_ config: GitHubConfig) {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() -> GitHubConfig {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(GitHubConfig.self, from: data) {
            return decoded
        }
        return GitHubConfig.empty
    }
}
