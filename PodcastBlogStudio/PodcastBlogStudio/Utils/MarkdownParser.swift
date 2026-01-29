import Foundation

/// 负责处理 Markdown 文件内容的合成与解析
/// 这里实现“分离存储，动态合成”的策略
struct MarkdownParser {
    
    /// 将 Post 对象转换为带有 Frontmatter 的完整 Markdown 字符串
    static func generateContent(for post: Post) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: post.createdAt)
        
        // 简单的 YAML Frontmatter 构造
        let frontmatter = """
        ---
        title: "\(post.title)"
        date: \(dateStr)
        ---
        
        """
        
        return frontmatter + post.content
    }
    
    /// (预留) 从文件内容解析出 Post 基本信息
    /// 目前 V1 新建文章为主，后续读取本地文件时会用到此方法
    static func parse(fileContent: String) -> (title: String, date: Date?, body: String) {
        // 简单实现：暂时只返回原始内容，后续配合 Regex 完善
        // TODO: 实现 Frontmatter 正则解析
        return (title: "Untitled", date: nil, body: fileContent)
    }
}