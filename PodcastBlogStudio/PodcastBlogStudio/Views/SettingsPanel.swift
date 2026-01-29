//
//  SettingsPanel.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

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

                    // --- 优化: 使用 SecureField 并增加说明 ---
                    SecureField("Personal Access Token (repo scope)", text: $appState.gitHubConfig.token)
                        .textFieldStyle(.roundedBorder)

                    Text("Required scope: repo")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    // --- 暂时注释掉 Check Token，Step 3 实现 ---
                    /*
                     Button(action: { }) {
                         Label("Check Token", systemImage: "person.badge.key")
                             .frame(maxWidth: .infinity)
                     }
                     .controlSize(.large)
                     */
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
        .overlay(
            Rectangle()
                .fill(Color(nsColor: .separatorColor))
                .frame(width: 1), // 1像素宽的线
            alignment: .leading // 贴在左边缘
        )
    }
}
