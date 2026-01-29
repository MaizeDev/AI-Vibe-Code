import Foundation

/// 本地文件管理服务
final class FileService: FileServiceProtocol {
    
    private let fileManager = FileManager.default
    
    /// 根目录：Documents/PodcastBlogStudio/posts/
    private var postsDirectoryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appending(path: "PodcastBlogStudio/posts")
    }
    
    init() {
        // 初始化时确保存储目录存在
        try? createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: postsDirectoryURL.path(percentEncoded: false)) {
            try fileManager.createDirectory(at: postsDirectoryURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Save
    
    func save(post: Post) async throws {
        // 1. 确保目录存在
        try createDirectoryIfNeeded()
        
        // 2. 生成完整内容 (Frontmatter + Body)
        let fileContent = MarkdownParser.generateContent(for: post)
        
        // 3. 获取文件路径
        let fileURL = postsDirectoryURL.appending(path: post.fileName)
        
        // 4. 写入文件
        try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        print("💾 Saved post: \(fileURL.lastPathComponent)")
    }
    
    // MARK: - Load All
    
    func loadAllPosts() async throws -> [Post] {
        try createDirectoryIfNeeded()
        
        // 1. 获取目录下所有 .md 文件
        let resourceKeys: [URLResourceKey] = [.creationDateKey, .contentModificationDateKey]
        let fileURLs = try fileManager.contentsOfDirectory(at: postsDirectoryURL, 
                                                           includingPropertiesForKeys: resourceKeys)
            .filter { $0.pathExtension == "md" }
        
        var loadedPosts: [Post] = []
        
        // 2. 遍历读取
        for url in fileURLs {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let parsed = MarkdownParser.parse(fileContent: content)
                
                // 从文件属性获取修改时间
                let values = try url.resourceValues(forKeys: Set(resourceKeys))
                let updatedAt = values.contentModificationDate ?? Date()
                
                // 构造 Post 对象
                let post = Post(
                    id: UUID(), // 这里的 ID 每次启动会变，MVP 暂且接受。若需固定 ID，需存入 Frontmatter
                    title: parsed.title,
                    content: parsed.body,
                    createdAt: parsed.date,
                    remoteSHA: parsed.sha
                )
                // 修正 fileName (以实际文件名为准)
                var finalPost = post
                finalPost.fileName = url.lastPathComponent
                finalPost.updatedAt = updatedAt
                
                loadedPosts.append(finalPost)
            } catch {
                print("❌ Failed to load file: \(url.lastPathComponent)")
            }
        }
        
        // 3. 按日期倒序排列
        return loadedPosts.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Delete
    
    func delete(post: Post) async throws {
        let fileURL = postsDirectoryURL.appending(path: post.fileName)
        if fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            try fileManager.removeItem(at: fileURL)
            print("🗑 Deleted file: \(post.fileName)")
        }
    }
}