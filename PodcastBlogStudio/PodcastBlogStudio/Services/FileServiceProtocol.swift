import Foundation

/// 本地文件管理协议
protocol FileServiceProtocol {
    func save(post: Post) async throws
    func loadAllPosts() async throws -> [Post]
    func delete(post: Post) async throws
}

/// GitHub API 交互协议
protocol GitHubServiceProtocol {
    /// 发布或更新文章
    /// 返回：GitHub 生成的最新的 SHA 值
    func publish(post: Post, config: GitHubConfig) async throws -> String
    
    /// 删除远程文章
    func delete(post: Post, config: GitHubConfig) async throws
}