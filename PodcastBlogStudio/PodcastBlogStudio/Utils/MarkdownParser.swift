//
//  MarkdownParser.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import Foundation

struct MarkdownParser {
    
    // MARK: - Writer (Model -> String)
    
    static func generateContent(for post: Post) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: post.createdAt)
        
        let shaLine = post.remoteSHA != nil ? "sha: \(post.remoteSHA!)\n" : ""
        
        // 构造 YAML Frontmatter
        // 注意：这里我们把 remoteSHA 也存进去，方便下次读取
        let frontmatter = """
        ---
        title: \(post.title)
        date: \(dateStr)
        \(shaLine)---
        
        """
        
        return frontmatter + post.content
    }
    
    // MARK: - Reader (String -> Model Data)
    
    /// 解析文件内容，返回元数据和正文
    static func parse(fileContent: String) -> (title: String, date: Date, sha: String?, body: String) {
        var title = "Untitled"
        var date = Date()
        var sha: String? = nil
        var body = fileContent
        
        // 1. 检查是否有 Frontmatter (以 --- 开头)
        let pattern = #"^---\n([\s\S]*?)\n---\n"# // 匹配两个 --- 之间的内容
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines),
           let match = regex.firstMatch(in: fileContent, range: NSRange(fileContent.startIndex..., in: fileContent)) {
            
            // 提取 Frontmatter 字符串
            if let range = Range(match.range(at: 1), in: fileContent) {
                let metadataStr = String(fileContent[range])
                
                // 解析每一行 key: value
                metadataStr.enumerateLines { line, _ in
                    let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        let key = parts[0]
                        let value = parts[1]
                        
                        switch key {
                        case "title":
                            title = value
                        case "date":
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let d = formatter.date(from: value) {
                                date = d
                            }
                        case "sha":
                            sha = value
                        default: break
                        }
                    }
                }
            }
            
            // 提取正文 (去掉 Frontmatter 部分)
            if let range = Range(match.range, in: fileContent) {
                body = String(fileContent[range.upperBound...])
            }
        }
        
        return (title, date, sha, body)
    }
}
