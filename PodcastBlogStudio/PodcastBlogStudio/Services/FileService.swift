//
//  FileService.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import Foundation

final class FileService: FileServiceProtocol {
    
    private let fileManager = FileManager.default
    
    // ... (之前的 postsDirectoryURL 和 init 保持不变) ...
    private var postsDirectoryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appending(path: "PodcastBlogStudio/posts")
    }
    
    init() {
        // 建议保留打印路径，方便后续调试
        print("📂 Local Storage Path: \(postsDirectoryURL.path(percentEncoded: false))")
        try? createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: postsDirectoryURL.path(percentEncoded: false)) {
            try fileManager.createDirectory(at: postsDirectoryURL, withIntermediateDirectories: true)
        }
    }

    // ... (save 和 loadAllPosts 保持不变) ...
    
    func save(post: Post) async throws {
        try createDirectoryIfNeeded()
        let fileContent = MarkdownParser.generateContent(for: post)
        let fileURL = postsDirectoryURL.appending(path: post.fileName)
        try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        // print("💾 Saved: \(post.fileName)") // 日志太多可以注释掉
    }
    
    func loadAllPosts() async throws -> [Post] {
        // ... (保持之前的代码不变) ...
        // 为了节省篇幅，这里省略 loadAllPosts 的具体实现，请保持原样
        // 只需要确保 delete 方法也在即可
        try createDirectoryIfNeeded()
        let resourceKeys: [URLResourceKey] = [.creationDateKey, .contentModificationDateKey]
        let fileURLs = try fileManager.contentsOfDirectory(at: postsDirectoryURL, includingPropertiesForKeys: resourceKeys)
            .filter { $0.pathExtension == "md" }
        
        var loadedPosts: [Post] = []
        for url in fileURLs {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let parsed = MarkdownParser.parse(fileContent: content)
                let values = try url.resourceValues(forKeys: Set(resourceKeys))
                let updatedAt = values.contentModificationDate ?? Date()
                
                var post = Post(
                    id: UUID(),
                    title: parsed.title,
                    content: parsed.body,
                    createdAt: parsed.date,
                    remoteSHA: parsed.sha
                )
                // 关键：加载时必须用实际文件名覆盖，确保同步
                post.fileName = url.lastPathComponent
                post.updatedAt = updatedAt
                loadedPosts.append(post)
            } catch { print("❌ Load error: \(error)") }
        }
        return loadedPosts.sorted { $0.createdAt > $1.createdAt }
    }
    
    func delete(post: Post) async throws {
        let fileURL = postsDirectoryURL.appending(path: post.fileName)
        if fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            try fileManager.removeItem(at: fileURL)
            print("🗑 Deleted: \(post.fileName)")
        }
    }
    
    // MARK: - Rename
        
        /// 重命名文件
        /// - Parameters:
        ///   - oldFileName: 旧文件名 (e.g. "untitled.md")
        ///   - newFileName: 新文件名 (e.g. "hello.md")
        func rename(oldFileName: String, newFileName: String) async throws {
            let oldURL = postsDirectoryURL.appending(path: oldFileName)
            let newURL = postsDirectoryURL.appending(path: newFileName)
            
            // 1. 基本检查
            if oldURL == newURL { return }
            
            // 2. 确保原文件存在才移动
            if fileManager.fileExists(atPath: oldURL.path(percentEncoded: false)) {
                
                // 安全措施：如果目标文件已存在（极少情况），先删除目标，防止报错
                if fileManager.fileExists(atPath: newURL.path(percentEncoded: false)) {
                    try fileManager.removeItem(at: newURL)
                }
                
                try fileManager.moveItem(at: oldURL, to: newURL)
                print("✏️ Renamed on Disk: \(oldFileName) -> \(newFileName)")
            } else {
                // 如果原文件找不到（可能是还没保存过），则不做移动，交由后续的 save() 去创建新文件
                print("⚠️ Rename source not found: \(oldFileName). Will create new file via save().")
            }
        }
}
