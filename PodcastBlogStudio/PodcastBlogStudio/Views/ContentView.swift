//
//  ContentView.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧 + 中间
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
            
            // 右侧设置面板 (类似 Inspector)
            if appState.isShowingSettings {
                SettingsPanel(appState: appState)
                    .transition(.move(edge: .trailing))
            }
        }
        // 顶部工具栏
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { appState.createPost() }) {
                    Label("New", systemImage: "plus")
                }
                
                Button(action: { /* TODO: Publish */ }) {
                    Label("Publish", systemImage: "paperplane")
                }
                
                Button(action: {
                    if let id = appState.selection { appState.deletePost(id: id) }
                }) {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(appState.selection == nil)
                
                Button(action: { /* TODO: Sync */ }) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            // 右侧开关设置面板的按钮
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
        // 初始设置：默认显示设置面板，方便调试
        .onAppear {
            appState.isShowingSettings = true
        }
    }
}

#Preview {
    ContentView()
}
