//
//  SearchView.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI

/// 搜索页面，允许用户搜索电影
struct SearchView: View {
    /// 应用状态管理器，用于获取电影数据
    @Environment(AppStore.self) private var store
    /// 搜索文本状态
    @State private var searchText = ""
    
    /// 根据搜索文本过滤的电影列表
    var filteredMovies: [Movie] {
        if searchText.isEmpty { return [] }
        return store.movies.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.originalTitle.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    // 如果搜索框为空，显示提示信息
                    ContentUnavailableView("Search Ghibli", systemImage: "magnifyingglass", description: Text("Find your favorite magic."))
                } else if filteredMovies.isEmpty {
                    // 如果没有匹配结果，显示未找到信息
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredMovies) { movie in
                        NavigationLink(value: movie) {
                            HStack {
                                AsyncImage(url: URL(string: movie.image)) { img in
                                    img.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 75)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading) {
                                    Text(movie.title).font(.headline)
                                    Text(movie.originalTitle).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}