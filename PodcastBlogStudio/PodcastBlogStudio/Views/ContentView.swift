import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        HStack(spacing: 0) {
            NavigationSplitView {
                SidebarView(appState: appState)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            } detail: {
                if let selectedId = appState.selection,
                   let post = appState.posts.first(where: { $0.id == selectedId }) {
                    EditorView(post: post, appState: appState)
                } else {
                    ContentUnavailableView("Select a Post", systemImage: "doc.text")
                }
            }
            
            if appState.isShowingSettings {
                SettingsPanel(appState: appState)
                    .transition(.move(edge: .trailing))
            }
        }
        // 使用抽离后的 Toolbar
        .toolbar {
            MainToolbar(appState: appState)
        }
        .onAppear {
            appState.isShowingSettings = true // 方便调试，发布时可改为 false
        }
        .task {
            await appState.loadPosts()
        }
        .alert("Error", isPresented: $appState.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(appState.errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    ContentView()
}
