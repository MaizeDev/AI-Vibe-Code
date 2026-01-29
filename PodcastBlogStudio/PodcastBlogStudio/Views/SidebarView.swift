//
//  SidebarView.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import SwiftUI

struct SidebarView: View {
    @Bindable var appState: AppState

    var body: some View {
        List(selection: $appState.selection) {
            Section(header: Text("Posts")) {
                ForEach(appState.posts) { post in
                    NavigationLink(value: post.id) {
                        HStack {
                            // 修改显示逻辑
                            if post.title.isEmpty {
                                Text("Untitled")
                                    .font(.body)
                                    .foregroundStyle(.secondary) // 灰色显示
                                    .italic()
                            } else {
                                Text(post.title)
                                    .font(.body)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(post.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .listStyle(.sidebar) // macOS 标准侧边栏样式
        // 移除默认的 navigationTitle，因为设计图没有大标题
    }
}
