import SwiftUI
import Observation

@Observable
final class AppState {
    
    // MARK: - State Properties
    var posts: [Post] = []
    var selection: Post.ID?
    
    // 监听配置变化，自动调用 Service 保存
    var gitHubConfig: GitHubConfig {
        didSet { settingsService.save(gitHubConfig) }
    }
    
    var isShowingSettings: Bool = false
    var isPublishing: Bool = false
    var saveStatus: String = "All Synced"
    
    // Error Handling
    var errorMessage: String?
    var showError: Bool = false
    
    // MARK: - Dependencies
    private let fileService: FileServiceProtocol
    private let gitHubService: GitHubServiceProtocol
    private let settingsService: SettingsServiceProtocol
    
    // Debounce Task
    private var saveTask: Task<Void, Error>?
    
    // MARK: - Initialization
    init(fileService: FileServiceProtocol = FileService(),
         gitHubService: GitHubServiceProtocol = GitHubService(),
         settingsService: SettingsServiceProtocol = SettingsService()) {
        
        self.fileService = fileService
        self.gitHubService = gitHubService
        self.settingsService = settingsService
        
        // 从 Service 加载配置
        self.gitHubConfig = settingsService.load()
    }
    
    // MARK: - Actions
    
    func loadPosts() async {
        do {
            let loaded = try await fileService.loadAllPosts()
            await MainActor.run { self.posts = loaded }
        } catch {
            displayError("Failed to load posts: \(error.localizedDescription)")
        }
    }
    
    func createPost() {
        let newPost = Post(title: "", content: "")
        posts.insert(newPost, at: 0)
        selection = newPost.id
        saveToDiskImmediately(post: newPost)
    }
    
    func deletePost(id: Post.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        let post = posts[index]
        posts.remove(at: index)
        if selection == id { selection = nil }
        
        Task { try? await fileService.delete(post: post) }
    }
    
    func updateSelectedPost(title: String, content: String) {
        guard let id = selection,
              let index = posts.firstIndex(where: { $0.id == id }) else { return }
        
        // 1. Update Memory (UI)
        posts[index].title = title
        posts[index].content = content
        posts[index].updatedAt = Date()
        
        saveStatus = "Typing..."
        
        // 2. Debounce Save
        saveTask?.cancel()
        let currentPost = posts[index]
        
        saveTask = Task {
            try await Task.sleep(for: .milliseconds(800))
            if Task.isCancelled { return }
            await performDiskSync(postSnapshot: currentPost, index: index)
        }
    }
    
    func publishSelectedPost() {
        guard let id = selection,
              let index = posts.firstIndex(where: { $0.id == id }) else { return }
        
        let post = posts[index]
        guard gitHubConfig.isValid else {
            displayError("Please configure GitHub settings first.")
            isShowingSettings = true
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                let newSHA = try await gitHubService.publish(post: post, config: gitHubConfig)
                await MainActor.run {
                    if posts.indices.contains(index) {
                        posts[index].remoteSHA = newSHA
                        posts[index].updatedAt = Date()
                        saveToDiskImmediately(post: posts[index])
                        saveStatus = "Published"
                        isPublishing = false
                    }
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    displayError(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    @MainActor
    private func performDiskSync(postSnapshot: Post, index: Int) async {
        guard posts.indices.contains(index), posts[index].id == postSnapshot.id else { return }
        
        saveStatus = "Saving..."
        let oldFileName = posts[index].fileName
        let newFileName = Post.generateFileName(title: postSnapshot.title, date: postSnapshot.createdAt, id: postSnapshot.id)
        
        do {
            if newFileName != oldFileName {
                try await fileService.rename(oldFileName: oldFileName, newFileName: newFileName)
                posts[index].fileName = newFileName
            }
            try await fileService.save(post: posts[index])
            saveStatus = "Saved"
        } catch {
            print("Disk Sync Error: \(error)")
            saveStatus = "Failed"
        }
    }
    
    private func saveToDiskImmediately(post: Post) {
        Task { try? await fileService.save(post: post) }
    }
    
    private func displayError(_ message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
