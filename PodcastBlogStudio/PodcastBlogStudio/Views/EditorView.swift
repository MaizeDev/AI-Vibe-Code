//
//  EditorView.swift
//  PodcastBlogStudio
//
//  Created by wheat on 1/29/26.
//


import SwiftUI

struct EditorView: View {
    let post: Post
    var appState: AppState
    
    @State private var title: String
    @State private var content: String
    
    init(post: Post, appState: AppState) {
        self.post = post
        self.appState = appState
        _title = State(initialValue: post.title)
        _content = State(initialValue: post.content)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1. 大标题输入框
            TextField("Enter Title", text: $title)
                .font(.system(size: 28, weight: .bold)) // 模仿设计图的大字体
                .textFieldStyle(.plain) // 去掉默认边框
                .padding(.horizontal)
                .padding(.top, 20)
                .onChange(of: title) { _, newValue in
                    appState.updateSelectedPost(title: newValue, content: content)
                }
            
            Divider()
                .padding(.horizontal)
            
            // 2. 正文编辑区
            TextEditor(text: $content)
                .font(.body) // 后续可换成等宽字体 .monospaced()
                .scrollContentBackground(.hidden) // 让背景透明以便统一调色
                .padding(.horizontal)
                .padding(.bottom)
                .onChange(of: content) { _, newValue in
                    appState.updateSelectedPost(title: title, content: newValue)
                }
        }
        .background(Color(nsColor: .textBackgroundColor)) // 编辑区白色背景
        .onChange(of: post.id) { _, _ in
            title = post.title
            content = post.content
        }
    }
}
