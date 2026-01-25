//
//  SearchView.swift
//  notes
//
//  Created by wheat on 1/22/26.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var context // 需要 context 来执行删除
    @Query(sort: \Note.creationDate, order: .reverse) private var allNotes: [Note]
    @State private var searchText: String = ""

    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return allNotes
        } else {
            return allNotes.filter {note in
                note.fullText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            // ✅ 改用 List 以支持 SwipeActions
            List {
                ForEach(filteredNotes) { note in
                    ZStack {
                        NavigationLink(value: note) { EmptyView() }.opacity(0)
                        NoteCardView(note: note)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    // ✅ 左滑删除
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                context.delete(note)
                                // 搜索状态下最好手动保存一下，虽非必须
                                try? context.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain) // 去除 List 默认样式
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search notes"
            )
            .navigationTitle("Search")
            .navigationDestination(for: Note.self) { note in
                DetailView(note: note)
            }
            // 搜索结果为空时的提示
            .overlay {
                if filteredNotes.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }
}
