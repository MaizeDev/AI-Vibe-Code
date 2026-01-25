import Foundation
import Yams

struct PostMetadata: Codable, Equatable {
    var title: String = ""
    var date: String = ""
    var tags: [String] = []
    var categories: [String] = []
    var draft: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title, date, tags, categories, draft
    }
    
    init() {}
}

// 辅助工具类：负责把全文拆分成 "头信息" 和 "正文"
struct FrontmatterEngine {
    
    static func parse(document: String) -> (PostMetadata, String) {
        // 1. 按换行符把文档切成一行一行
        // 使用 .newlines 自动兼容 \n 和 \r\n
        let lines = document.components(separatedBy: .newlines)
        
        // 2. 检查第一行是不是 "---"
        guard let firstLine = lines.first, firstLine.trimmingCharacters(in: .whitespaces) == "---" else {
            // 没有检测到头部，全文返回
            return (PostMetadata(), document)
        }
        
        // 3. 寻找第二个 "---" 的位置
        var endLineIndex = -1
        for i in 1..<lines.count {
            if lines[i].trimmingCharacters(in: .whitespaces) == "---" {
                endLineIndex = i
                break
            }
        }
        
        // 4. 如果找到了闭合的 ---，进行拆分
        if endLineIndex != -1 {
            // 提取中间的 YAML
            let yamlLines = lines[1..<endLineIndex]
            let yamlString = yamlLines.joined(separator: "\n")
            
            // 提取后面的正文
            let contentLines = lines[(endLineIndex + 1)...]
            // 去除正文开头可能多余的空行
            let contentString = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 解析 YAML
            let decoder = YAMLDecoder()
            if let metadata = try? decoder.decode(PostMetadata.self, from: yamlString) {
                return (metadata, contentString)
            }
        }
        
        // 解析失败，返回默认
        return (PostMetadata(), document)
    }
    
    static func reconstruct(metadata: PostMetadata, content: String) -> String {
        let encoder = YAMLEncoder()
        do {
            var yaml = try encoder.encode(metadata)
            yaml = yaml.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 确保拼装时，正文上方只有一行空行，保持美观
            return "---\n\(yaml)\n---\n\n\(content)"
        } catch {
            print("YAML 编码失败: \(error)")
            return content
        }
    }
}
