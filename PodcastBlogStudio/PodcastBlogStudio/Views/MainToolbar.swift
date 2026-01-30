//
//  MainToolbar.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/30/26.
//


import SwiftUI

struct MainToolbar: ToolbarContent {
    @Bindable var appState: AppState
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: { appState.createPost() }) {
                Label("New", systemImage: "plus")
            }
            
            if appState.isPublishing {
                ProgressView().controlSize(.small).padding(.horizontal, 8)
            } else {
                Text(appState.saveStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
            
            Button(action: { appState.publishSelectedPost() }) {
                Label("Publish", systemImage: "paperplane")
            }
            .disabled(appState.selection == nil || appState.isPublishing)
            .keyboardShortcut("p", modifiers: .command)
            
            Button(action: {
                if let id = appState.selection,
                   let post = appState.posts.first(where: { $0.id == id }) {
                    // 修改这里：调用请求删除
                    appState.requestDelete(post: post)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
            .disabled(appState.selection == nil)
        }
        
        ToolbarItem(placement: .automatic) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    appState.isShowingSettings.toggle()
                }
            }) {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}
