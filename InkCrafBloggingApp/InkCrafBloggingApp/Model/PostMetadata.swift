import Foundation
import Yams

struct PostMetadata: Codable, Equatable {
    var title: String = ""
    var date: String = "" // 为了兼容各种格式，先存为 String，UI 上再转 Date
    var tags: [String] = []
    var categories: [String] = []
    var draft: Bool = false
    
    // 自定义键名映射 (有些博客用 tag 而不是 tags)
    enum CodingKeys: String, CodingKey {
        case title
        case date
        case tags, tag
        case categories, category
        case draft
    }
    
    // 初始化一个空的
    init() {}
}

// 辅助工具类：负责把全文拆分成 "头信息" 和 "正文"
struct FrontmatterEngine {
    
    // 结果元组：(解析出的元数据, 剩余的正文内容, 原始的YAML字符串)
    static func parse(document: String) -> (PostMetadata, String, String?) {
        let pattern = "^---\\n([\\s\\S]*?)\\n---\\n"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // 1. 尝试匹配头部的 --- ... ---
        if let match = regex.firstMatch(in: document, range: NSRange(document.startIndex..., in: document)) {
            let yamlRange = Range(match.range(at: 1), in: document)!
            let fullMatchRange = Range(match.range, in: document)!
            
            let yamlString = String(document[yamlRange])
            let contentString = String(document[fullMatchRange.upperBound...])
            
            // 2. 使用 Yams 解析 YAML
            let decoder = YAMLDecoder()
            do {
                let metadata = try decoder.decode(PostMetadata.self, from: yamlString)
                return (metadata, contentString, yamlString)
            } catch {
                print("YAML 解析失败: \(error)")
                // 解析失败返回空对象，但在正文里保留原始文本，防丢失
                return (PostMetadata(), document, nil)
            }
        }
        
        // 没有发现 Frontmatter
        return (PostMetadata(), document, nil)
    }
    
    // 把 元数据 + 正文 重新拼合成一个字符串
    static func reconstruct(metadata: PostMetadata, content: String) -> String {
        let encoder = YAMLEncoder()
        do {
            var yaml = try encoder.encode(metadata)
            // Yams 有时会在末尾多加换行，微调一下
            yaml = yaml.trimmingCharacters(in: .whitespacesAndNewlines)
            return "---\n\(yaml)\n---\n\n\(content)"
        } catch {
            print("YAML 编码失败: \(error)")
            return content
        }
    }
}