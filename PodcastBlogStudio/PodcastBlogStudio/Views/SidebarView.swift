import SwiftUI

struct SidebarView: View {
    @Bindable var appState: AppState
    
    var body: some View {
        List(selection: $appState.selection) {
            ForEach(appState.posts) { post in
                NavigationLink(value: post.id) {
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.createdAt.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Posts")
    }
}