//
//  AppState.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import Observation
import SwiftUI

@Observable
final class AppState {
    var posts: [Post] = []
    var selection: Post.ID?
    
    // --- 优化 1: 监听配置变化自动保存 ---
    var gitHubConfig: GitHubConfig {
        didSet {
            saveSettings()
        }
    }

    var isShowingSettings: Bool = false
    var saveStatus: String = "All Synced"
    
    // --- 优化 2: 错误提示 (为 Step 3 准备) ---
    var errorMessage: String?
    var showError: Bool = false

    private let fileService: FileService

    // --- 新增：用于防抖的异步任务 ---
    private var saveTask: Task<Void, Error>?

    init() {
        self.fileService = FileService()
        // 初始化时给一个空值，稍后在 loadSettings 中覆盖
        self.gitHubConfig = GitHubConfig.empty
        
        // 加载已保存的设置
        loadSettings()
    }

    // ... createPost, loadPosts, deletePost 代码保持不变 ...

    func loadPosts() async {
        do {
            let loaded = try await fileService.loadAllPosts()
            await MainActor.run { self.posts = loaded }
        } catch { print("Error loading: \(error)") }
    }

    func createPost() {
        // 保持之前的逻辑：创建空标题，文件名带UUID后缀
        let newPost = Post(title: "", content: "")
        posts.insert(newPost, at: 0)
        selection = newPost.id
        saveToDiskImmediately(post: newPost) // 新建时立即保存一次
    }

    func deletePost(id: Post.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        let post = posts[index]
        posts.remove(at: index)
        if selection == id { selection = nil }
        Task { try? await fileService.delete(post: post) }
    }

    // MARK: - 核心修复：带防抖的更新逻辑

    func updateSelectedPost(title: String, content: String) {
        guard let id = selection,
              let index = posts.firstIndex(where: { $0.id == id }) else { return }

        // 1. 立即更新内存中的 title 和 content，保证 UI 响应速度
        // 注意：此时不要改内存里的 fileName，等硬盘操作成功后再改
        posts[index].title = title
        posts[index].content = content
        posts[index].updatedAt = Date()

        // 设置 UI 状态
        saveStatus = "Typing..."

        // 2. 取消上一次未执行的保存任务 (防抖核心)
        saveTask?.cancel()

        // 3. 开启新的延迟任务
        let currentPost = posts[index] // 捕获当前的数据快照

        saveTask = Task {
            // 等待 0.8 秒。如果用户在这期间又打字了，这个 Task 会被 cancel() 停掉
            try await Task.sleep(for: .milliseconds(800))

            // 检查任务是否被取消
            if Task.isCancelled { return }

            // 执行真实的硬盘操作
            await performDiskSync(postSnapshot: currentPost, index: index)
        }
    }

    /// 执行真实的硬盘同步（重命名 + 保存）
    @MainActor
    private func performDiskSync(postSnapshot: Post, index: Int) async {
        // 再次检查越界，防止文章在保存前被删了
        guard posts.indices.contains(index), posts[index].id == postSnapshot.id else { return }

        saveStatus = "Saving..."

        // 1. 计算新的文件名
        let oldFileName = posts[index].fileName // 获取当前内存里的旧文件名
        let newFileName = Post.generateFileName(title: postSnapshot.title, date: postSnapshot.createdAt, id: postSnapshot.id)

        do {
            // 2. 如果文件名变了，先执行文件重命名
            if newFileName != oldFileName {
                // print("🔄 Renaming: \(oldFileName) -> \(newFileName)")
                // 只有当重命名成功后，才更新内存里的文件名
                try await fileService.rename(oldFileName: oldFileName, newFileName: newFileName)
                posts[index].fileName = newFileName
            }

            // 3. 保存内容 (使用新的文件名)
            // 此时必须重新从内存取最新的 Post (因为 fileName 可能刚更新)
            let postToSave = posts[index]
            try await fileService.save(post: postToSave)

            saveStatus = "Saved"
        } catch {
            print("❌ Disk Sync Failed: \(error)")
            saveStatus = "Failed"
        }
    }

    // 辅助：不防抖的立即保存 (用于新建文章)
    private func saveToDiskImmediately(post: Post) {
        Task {
            try? await fileService.save(post: post)
        }
    }
    
    // MARK: - Settings Persistence
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(gitHubConfig) {
            UserDefaults.standard.set(encoded, forKey: "GitHubConfig")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "GitHubConfig"),
           let decoded = try? JSONDecoder().decode(GitHubConfig.self, from: data) {
            self.gitHubConfig = decoded
        }
    }
    
    // 辅助方法：显示错误
    func displayError(_ message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
