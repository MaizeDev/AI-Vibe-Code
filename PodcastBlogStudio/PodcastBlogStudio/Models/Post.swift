//
//  Post.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var fileName: String
    var remoteSHA: String?
    
    var isPublished: Bool { remoteSHA != nil }
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), remoteSHA: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.remoteSHA = remoteSHA
        // 初始化时调用静态方法生成文件名，传入 id 以防重复
        self.fileName = Post.generateFileName(title: title, date: createdAt, id: id)
    }
    
    /// 静态辅助方法：根据标题、日期和ID生成文件名
    static func generateFileName(title: String, date: Date, id: UUID) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        // 核心修改：处理空标题
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // 如果标题为空，使用 "untitled-UUID前8位" 确保唯一性
            let uniqueSuffix = id.uuidString.prefix(8).lowercased()
            return "\(dateStr)-untitled-\(uniqueSuffix).md"
        }
        
        // 正常标题的处理逻辑
        let slug = title.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "-")
            .filter { "abcdefghijklmnopqrstuvwxyz0123456789-".contains($0) }
        
        let finalSlug = slug.isEmpty ? "post" : slug
        return "\(dateStr)-\(finalSlug).md"
    }
}
