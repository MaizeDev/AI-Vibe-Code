import SwiftUI

struct EditorView: View {
    let post: Post
    var appState: AppState
    
    // 使用本地 State 绑定编辑器的输入，只有保存时才回写到 AppState
    // 或者直接绑定到 AppState 的 Binding
    @State private var title: String
    @State private var content: String
    
    init(post: Post, appState: AppState) {
        self.post = post
        self.appState = appState
        _title = State(initialValue: post.title)
        _content = State(initialValue: post.content)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题输入区
            TextField("Title", text: $title)
                .font(.title)
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .onChange(of: title) { _, newValue in
                    appState.updateSelectedPost(title: newValue, content: content)
                }
            
            Divider()
            
            // 正文编辑区
            TextEditor(text: $content)
                .font(.body)
                .padding()
                .onChange(of: content) { _, newValue in
                    appState.updateSelectedPost(title: title, content: newValue)
                }
        }
        // 当切换文章时，更新本地 State
        .onChange(of: post.id) { _, _ in
            title = post.title
            content = post.content
        }
    }
}