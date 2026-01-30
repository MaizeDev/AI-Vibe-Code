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

                    SecureField("Personal Access Token (repo scope)", text: $appState.gitHubConfig.token)
                        .textFieldStyle(.roundedBorder)

                    Text("Required scope: repo")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Divider()

                // Section 2: Repository Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repository")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Owner (Username)")
                        .font(.caption)
                    TextField("e.g. MaizeDev", text: $appState.gitHubConfig.owner)
                        .textFieldStyle(.roundedBorder)

                    Text("Repo Name")
                        .font(.caption)
                    TextField("e.g. MaizeDev.github.io", text: $appState.gitHubConfig.repo)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                // Section 3: Hexo Configuration (关键修复)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hexo Configuration")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // --- 修复：新增 Branch 输入框 ---
                    Text("Source Branch")
                        .font(.caption)
                    TextField("e.g. source", text: $appState.gitHubConfig.branch)
                        .textFieldStyle(.roundedBorder)
                    Text("Must match your Hexo source code branch")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    // --- Folder Path ---
                    Text("Post Path")
                        .font(.caption)
                    TextField("e.g. source/_posts", text: $appState.gitHubConfig.path)
                        .textFieldStyle(.roundedBorder)
                }

                Divider()

                // Section 4: Blog URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blog URL")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("https://myblog.github.io", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                }

                Spacer()
            }
            .padding()
        }
        .frame(width: 260)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color(nsColor: .separatorColor))
                .frame(width: 1),
            alignment: .leading
        )
    }
}
