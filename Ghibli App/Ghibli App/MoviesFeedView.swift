//
//  MoviesFeedView.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//

import SwiftUI
import SwiftData // <--- 确保这里也有，因为用到了 @Query

/// 电影列表页面，展示所有电影
struct MoviesFeedView: View {
    /// 应用状态管理器，用于获取电影数据
    @Environment(AppStore.self) private var store
    /// SwiftData上下文，用于管理数据
    @Environment(\.modelContext) private var modelContext
    
    /// 查询收藏的电影列表
    @Query private var favorites: [FavoriteMovie]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if store.isLoading {
                        ProgressView("Loading Ghibli Universe...")
                            .padding(.top, 50)
                    } else {
                        ForEach(store.movies) { movie in
                            NavigationLink(value: movie) {
                                MovieCard(
                                    movie: movie,
                                    isFavorite: favorites.contains(where: { $0.id == movie.id }),
                                    onToggleFavorite: { toggleFavorite(movie) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Movies")
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
            .task {
                await store.loadMovies()
            }
        }
    }
    
    /// 切换电影收藏状态
    /// - Parameter movie: 要切换收藏状态的电影
    private func toggleFavorite(_ movie: Movie) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if let existing = favorites.first(where: { $0.id == movie.id }) {
            modelContext.delete(existing)
        } else {
            let newFav = FavoriteMovie(from: movie)
            modelContext.insert(newFav)
        }
    }
}