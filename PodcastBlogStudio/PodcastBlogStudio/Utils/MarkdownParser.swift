import Foundation

struct MarkdownParser {
    
    // MARK: - Writer
    
    static func generateContent(for post: Post) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: post.createdAt)
        
        var yamlContent = "title: \(post.title)\ndate: \(dateStr)"
        
        // 如果有 SHA，也存入 Frontmatter (作为隐藏元数据)
        if let sha = post.remoteSHA {
            yamlContent += "\nsha: \(sha)"
        }
        
        // 构造标准的 Frontmatter
        let frontmatter = """
        ---
        \(yamlContent)
        ---
        
        """
        
        return frontmatter + post.content
    }
    
    // MARK: - Reader
    
    /// 解析文件内容
    static func parse(fileContent: String) -> (title: String, date: Date, sha: String?, body: String) {
        var title = "Untitled"
        var date = Date()
        var sha: String? = nil
        var body = fileContent
        
        // 正则匹配 YAML Frontmatter
        // 匹配规则：以 --- 开头，中间非贪婪匹配任意字符，以 --- 结尾
        let pattern = #"^---\n([\s\S]*?)\n---\n"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines),
           let match = regex.firstMatch(in: fileContent, range: NSRange(fileContent.startIndex..., in: fileContent)) {
            
            // 1. 提取元数据区
            if let range = Range(match.range(at: 1), in: fileContent) {
                let metadataStr = String(fileContent[range])
                let parsedMeta = parseYaml(metadataStr)
                
                if let t = parsedMeta["title"] { title = t }
                if let dStr = parsedMeta["date"], let d = parseDate(dStr) { date = d }
                if let s = parsedMeta["sha"] { sha = s }
            }
            
            // 2. 提取正文
            if let range = Range(match.range, in: fileContent) {
                body = String(fileContent[range.upperBound...])
            }
        }
        
        return (title, date, sha, body)
    }
    
    // MARK: - Helpers
    
    private static func parseYaml(_ content: String) -> [String: String] {
        var result: [String: String] = [:]
        content.enumerateLines { line, _ in
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                result[parts[0]] = parts[1]
            }
        }
        return result
    }
    
    private static func parseDate(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        // 尝试多种日期格式，兼容 Hexo 常见的格式
        let formats = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm", "yyyy-MM-dd"]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateStr) {
                return date
            }
        }
        return nil
    }
}
