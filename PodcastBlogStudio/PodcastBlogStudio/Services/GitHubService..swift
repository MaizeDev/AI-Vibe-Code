//
//  GitHubError.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import Foundation

enum GitHubError: Error, LocalizedError {
    case invalidConfig
    case invalidURL
    case apiError(String)
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidConfig: return "Please check your GitHub settings (Token/Repo)."
        case .invalidURL: return "Invalid URL construction."
        case .apiError(let msg): return "GitHub API Error: \(msg)"
        case .noData: return "No data received from GitHub."
        case .decodingError: return "Failed to decode response."
        }
    }
}

final class GitHubService: GitHubServiceProtocol {
    
    // MARK: - Response Models
    // 用于解析 GitHub API 返回的 JSON
    struct GitHubFileResponse: Decodable {
        let content: ContentInfo?
        struct ContentInfo: Decodable {
            let sha: String
        }
    }
    
    // MARK: - Request Models
    // 用于构造发送给 API 的 JSON
    struct PutFileRequest: Encodable {
        let message: String
        let content: String // Base64 encoded
        let sha: String?    // Required if updating
        let branch: String?
    }
    
    // MARK: - Implementation
    
    func publish(post: Post, config: GitHubConfig) async throws -> String {
        guard config.isValid else { throw GitHubError.invalidConfig }
        
        // 1. 准备 URL: https://api.github.com/repos/{owner}/{repo}/contents/{path}
        let baseURL = "https://api.github.com/repos/\(config.owner)/\(config.repo)/contents/\(post.fileName)"
        guard let url = URL(string: baseURL) else { throw GitHubError.invalidURL }
        
        // 2. 准备请求内容
        // 生成完整的 Markdown 字符串 (包含 Frontmatter)
        let markdownString = MarkdownParser.generateContent(for: post)
        // GitHub API 要求内容必须是 Base64 编码
        guard let contentData = markdownString.data(using: .utf8) else { throw GitHubError.decodingError }
        let base64Content = contentData.base64EncodedString()
        
        // 构造请求体
        let body = PutFileRequest(
            message: "Publish: \(post.title)", // Commit message
            content: base64Content,
            sha: post.remoteSHA, // 如果是更新，必须传旧的 SHA
            branch: config.branch.isEmpty ? "main" : config.branch
        )
        
        // 3. 构造 URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("token \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)
        
        print("🚀 Publishing to: \(url.absoluteString)")
        
        // 4. 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. 检查状态码
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                // 尝试解析错误信息
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
                print("❌ API Error [\(httpResponse.statusCode)]: \(errorMsg)")
                
                if httpResponse.statusCode == 401 { throw GitHubError.apiError("Unauthorized. Check your Token.") }
                if httpResponse.statusCode == 404 { throw GitHubError.apiError("Repo not found.") }
                if httpResponse.statusCode == 409 { throw GitHubError.apiError("Conflict. Try syncing first.") }
                throw GitHubError.apiError("Status \(httpResponse.statusCode)")
            }
        }
        
        // 6. 解析返回的新 SHA
        let decodedResponse = try JSONDecoder().decode(GitHubFileResponse.self, from: data)
        guard let newSHA = decodedResponse.content?.sha else {
            throw GitHubError.decodingError
        }
        
        print("✅ Published Successfully! New SHA: \(newSHA)")
        return newSHA
    }
    
    func delete(post: Post, config: GitHubConfig) async throws {
        // 删除逻辑暂略，先集中精力跑通发布
        // 逻辑类似：DELETE 方法，也需要传 sha
    }
}