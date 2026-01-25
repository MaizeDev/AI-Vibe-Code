//
//  FavoritesView.swift
//  notes
//
//  Created by wheat on 1/22/26.
//
import SwiftUI
import SwiftData

// FavoritesView.swift
struct FavoritesView: View {
    @Environment(\.modelContext) private var context
    
    @Query(
        filter: #Predicate<Note> { note in
            note.isFavorite == true
        },
        sort: [SortDescriptor(\Note.creationDate, order: .reverse)]
    )
    private var notes: [Note]
    
    var body: some View {
        NavigationStack {
            // ❌ 移除 ScrollView + LazyVStack
            // ✅ 改用 List
            List {
                ForEach(notes) { note in
                    ZStack {
                        NavigationLink(value: note) { EmptyView() }.opacity(0)
                        NoteCardView(note: note)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { context.delete(note) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain) // 记得加这个
            .navigationTitle("Favorites")
            .navigationDestination(for: Note.self) { note in
                DetailView(note: note)
            }
            // 如果列表为空，显示提示
            .overlay {
                if notes.isEmpty {
                    ContentUnavailableView("No Favorites", systemImage: "star.slash", description: Text("Mark notes as favorite to see them here."))
                }
            }
        }
    }
}
