//
//  FavoritesView.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI
import SwiftData

/// 收藏页面，展示用户收藏的电影
struct FavoritesView: View {
    /// 查询收藏的电影列表，按时间倒序排列
    @Query(sort: \FavoriteMovie.timestamp, order: .reverse) var favorites: [FavoriteMovie]
    /// SwiftData上下文，用于管理数据
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    // 如果没有收藏，显示空状态
                    ContentUnavailableView("No Favorites", systemImage: "heart.slash", description: Text("Your collection is empty."))
                } else {
                    List {
                        ForEach(favorites) { fav in
                            // 转换回 Movie 对象以便复用 DetailView
                            let movie = Movie(id: fav.id, title: fav.title, originalTitle: "", image: fav.image, movieBanner: "", description: fav.desc, director: "", releaseDate: "", runningTime: "", rtScore: "")
                            
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                HStack {
                                    AsyncImage(url: URL(string: fav.image)) { i in i.resizable() } placeholder: { Color.gray }
                                        .frame(width: 60, height: 90)
                                        .cornerRadius(8)
                                    Text(fav.title).font(.headline)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(favorites[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}