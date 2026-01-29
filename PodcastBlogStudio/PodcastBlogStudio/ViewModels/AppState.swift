import SwiftUI
import Observation

/// 全局应用状态
/// 使用 @Observable 宏 (Swift 6)
@Observable
final class AppState {
    
    // MARK: - Properties
    
    /// 文章列表
    var posts: [Post] = []
    
    /// 当前选中的文章 ID (用于 Sidebar 导航)
    var selection: Post.ID?
    
    /// GitHub 配置
    var gitHubConfig: GitHubConfig
    
    /// UI 状态：是否显示设置页
    var isShowingSettings: Bool = false
    
    // MARK: - Dependencies
    // 暂时用占位符，后续步骤实现具体 Service 后注入
    // let fileService: FileServiceProtocol
    // let gitHubService: GitHubServiceProtocol
    
    // MARK: - Initialization
    
    init() {
        self.gitHubConfig = GitHubConfig.empty
        // 模拟一些数据用于预览 UI
        self.posts = [
            Post(title: "Hello World", content: "This is my first post."),
            Post(title: "SwiftUI Tips", content: "Details about SwiftUI 6...")
        ]
    }
    
    // MARK: - Actions (CRUD)
    
    /// 新建文章
    func createPost() {
        let newPost = Post(title: "New Post", content: "")
        posts.insert(newPost, at: 0)
        selection = newPost.id // 自动选中新建的文章
        // TODO: 调用 fileService.save
    }
    
    /// 删除文章
    func deletePost(id: Post.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        // let post = posts[index]
        
        posts.remove(at: index)
        if selection == id {
            selection = nil
        }
        
        // TODO: 调用 fileService.delete & gitHubService.delete
    }
    
    /// 更新当前选中的文章内容
    func updateSelectedPost(title: String, content: String) {
        guard let id = selection,
              let index = posts.firstIndex(where: { $0.id == id }) else { return }
        
        var post = posts[index]
        post.title = title
        post.content = content
        post.updatedAt = Date()
        
        posts[index] = post
        // TODO: 触发自动保存逻辑
    }
}