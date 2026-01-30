//
//  GitHubError.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/30/26.
//

import Foundation

enum GitHubError: Error, LocalizedError {
    case invalidConfig
    case invalidURL
    case apiError(String)
    case noData
    case decodingError
    case missingSHA // 删除时必须有 SHA
    
    var errorDescription: String? {
        switch self {
        case .invalidConfig: return "Please check your GitHub settings (Token/Repo)."
        case .invalidURL: return "Invalid URL construction."
        case .apiError(let msg): return "GitHub API Error: \(msg)"
        case .noData: return "No data received from GitHub."
        case .decodingError: return "Failed to decode response."
        case .missingSHA: return "Cannot delete file without SHA. Is it published?"
        }
    }
}