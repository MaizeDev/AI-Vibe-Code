//
//  GitHubService.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import Foundation

// MARK: - Service Implementation
final class GitHubService: GitHubServiceProtocol {
    
    // MARK: - Response Models
    struct GitHubFileResponse: Decodable {
        let content: ContentInfo?
        struct ContentInfo: Decodable { let sha: String }
    }
    
    // MARK: - Request Models
    struct PutFileRequest: Encodable {
        let message: String
        let content: String
        let sha: String?
        let branch: String?
    }
    
    struct DeleteFileRequest: Encodable {
        let message: String
        let sha: String
        let branch: String?
    }
    
    // MARK: - Publish (Create or Update)
    
    func publish(post: Post, config: GitHubConfig) async throws -> String {
        guard config.isValid else { throw GitHubError.invalidConfig }
        
        // 1. 获取 URL (复用逻辑)
        let url = try buildURL(for: post, config: config)
        
        // 2. 准备内容
        let markdownString = MarkdownParser.generateContent(for: post)
        guard let contentData = markdownString.data(using: .utf8) else { throw GitHubError.decodingError }
        
        let body = PutFileRequest(
            message: "Publish: \(post.title)",
            content: contentData.base64EncodedString(),
            sha: post.remoteSHA,
            branch: config.branch.isEmpty ? "main" : config.branch
        )
        
        // 3. 构造请求
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("token \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)
        
        print("🚀 Publishing to: \(url.absoluteString)")
        
        // 4. 发送并处理
        let (data, _) = try await send(request: request)
        
        // 5. 解析新 SHA
        let decoded = try JSONDecoder().decode(GitHubFileResponse.self, from: data)
        guard let newSHA = decoded.content?.sha else {
            throw GitHubError.decodingError
        }
        
        return newSHA
    }
    
    // MARK: - Delete (Remove File)
    
    func delete(post: Post, config: GitHubConfig) async throws {
        guard config.isValid else { throw GitHubError.invalidConfig }
        // 删除文件必须提供 sha，否则 GitHub 不知道你删的是哪个版本
        guard let sha = post.remoteSHA else { throw GitHubError.missingSHA }
        
        // 1. 获取 URL
        let url = try buildURL(for: post, config: config)
        
        // 2. 构造请求体 (GitHub 删除 API 需要传 body)
        let body = DeleteFileRequest(
            message: "Delete: \(post.title)",
            sha: sha,
            branch: config.branch.isEmpty ? "main" : config.branch
        )
        
        // 3. 构造请求
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("token \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)
        
        print("🗑 Deleting remote file: \(url.absoluteString)")
        
        // 4. 发送 (不需要返回值，只要不报错就是成功)
        _ = try await send(request: request)
    }
    
    // MARK: - Private Helpers
    
    /// 统一构建文件 API 的 URL
    private func buildURL(for post: Post, config: GitHubConfig) throws -> URL {
        // 处理路径：去掉首尾的 /
        let folderPath = config.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        // 如果 path 为空则在根目录，否则拼接
        let fullFilePath = folderPath.isEmpty ? post.fileName : "\(folderPath)/\(post.fileName)"
        
        // 进行 URL 编码 (解决空格和特殊字符问题)
        guard let encodedPath = fullFilePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw GitHubError.invalidURL
        }
        
        let urlString = "https://api.github.com/repos/\(config.owner)/\(config.repo)/contents/\(encodedPath)"
        
        guard let url = URL(string: urlString) else {
            throw GitHubError.invalidURL
        }
        
        return url
    }
    
    /// 统一发送请求并处理 HTTP 状态码
    private func send(request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            // 200...299 都是成功 (PUT 返回 200/201, DELETE 返回 200/204)
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
                print("❌ API Error [\(httpResponse.statusCode)]: \(errorMsg)")
                
                switch httpResponse.statusCode {
                case 401: throw GitHubError.apiError("Unauthorized. Check Token.")
                case 404: throw GitHubError.apiError("File or Repo not found.")
                case 409: throw GitHubError.apiError("Conflict. Sync required.")
                case 422: throw GitHubError.apiError("Validation Failed.")
                default:  throw GitHubError.apiError("Status \(httpResponse.statusCode)")
                }
            }
        }
        return (data, response)
    }
}
