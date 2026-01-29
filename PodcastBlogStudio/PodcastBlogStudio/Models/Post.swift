import Foundation

/// 文章模型
/// 对应本地的一个 Markdown 文件
struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    /// 对应 GitHub 上的文件名 (e.g., "2023-10-01-hello.md")
    var fileName: String
    
    /// GitHub 文件的 SHA 值，用于更新文件时防止冲突
    /// 如果为 nil，表示尚未发布过
    var remoteSHA: String?
    
    /// 辅助属性：是否已发布
    var isPublished: Bool {
        return remoteSHA != nil
    }
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), remoteSHA: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.remoteSHA = remoteSHA
        
        // 自动生成文件名: yyyy-MM-dd-title-slug.md
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: createdAt)
        // 简单处理标题中的空格和特殊字符
        let slug = title.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "-")
            .filter { "abcdefghijklmnopqrstuvwxyz0123456789-".contains($0) }
        
        self.fileName = "\(dateStr)-\(slug).md"
    }
}