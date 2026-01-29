import SwiftUI

struct SettingsPanel: View {
    @Bindable var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                Text("Settings")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                // Section 1: GitHub Account
                VStack(alignment: .leading, spacing: 8) {
                    Text("GitHub Account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Personal Access Token", text: $appState.gitHubConfig.token)
                        .textFieldStyle(.roundedBorder)
                        // 实际开发中应该用 SecureField，但为了方便调试MVP先用TextField
                    
                    Button(action: { /* TODO: Validate Token */ }) {
                        Label("Check Token", systemImage: "person.badge.key")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                }
                
                Divider()
                
                // Section 2: Repository
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repository")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Owner (Username)")
                        .font(.caption)
                    TextField("e.g. apple", text: $appState.gitHubConfig.owner)
                        .textFieldStyle(.roundedBorder)

                    Text("Repo Name")
                        .font(.caption)
                    TextField("e.g. swift", text: $appState.gitHubConfig.repo)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                // Section 3: Blog URL (Optional for MVP)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blog URL")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Site Address:")
                        .font(.caption)
                    TextField("https://myblog.github.io", text: .constant("")) // 暂时占位
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 260) // 固定宽度，符合 Inspector 设计
        .background(Color(nsColor: .controlBackgroundColor)) // 略灰的背景
        .border(width: 1, edges: [.leading], color: Color(nsColor: .separatorColor))
    }
}