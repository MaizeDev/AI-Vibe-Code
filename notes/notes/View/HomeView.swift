//
//  HomeView.swift
//  notes
//
//  Created by wheat on 1/22/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.creationDate, order: .reverse) private var notes: [Note]
    
    var body: some View {
        NavigationStack {
            // 1️⃣ 改用 List
            List {
                ForEach(notes) { note in
                    ZStack {
                        // 隐式导航链接（为了隐藏列表右侧的小箭头 >）
                        NavigationLink(value: note) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        NoteCardView(note: note)
                    }
                    // 2️⃣ 必须设置 List 行样式，去除默认的内边距和背景
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden) // 隐藏分割线
                    .listRowBackground(Color.clear) // 透明背景
                    // 3️⃣ 添加左滑删除功能
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
            // 4️⃣ 设置 List 风格为 plain，防止出现圆角分组样式
            .listStyle(.plain)
            .navigationTitle("Home")
            .navigationDestination(for: Note.self) { note in
                DetailView(note: note)
            }
        }
    }
    
    // 删除逻辑
    private func deleteNote(_ note: Note) {
        withAnimation {
            context.delete(note)
        }
    }
}


#Preview {
    HomeView()
}
