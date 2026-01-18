//
//  MovieDetailView.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI

/// 电影详情页面，展示电影的完整信息
struct MovieDetailView: View {
    /// 要展示的电影数据
    let movie: Movie
    /// 用于关闭页面的环境变量
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 顶部 Banner
                AsyncImage(url: URL(string: movie.movieBanner)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(.gray.opacity(0.2))
                }
                .frame(height: 250)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 100)
                }

                VStack(alignment: .leading, spacing: 20) {
                    // 标题区
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(movie.originalTitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    // 数据统计行
                    HStack(spacing: 20) {
                        InfoBadge(icon: "clock", text: "\(movie.runningTime) min")
                        InfoBadge(icon: "star.fill", text: movie.rtScore, color: .yellow)
                        InfoBadge(icon: "calendar", text: movie.releaseDate)
                    }

                    Divider()

                    // 简介
                    Text("Story")
                        .font(.headline)

                    Text(movie.description)
                        .font(.body)
                        .lineSpacing(6)
                        .foregroundStyle(.secondary)

                    // 导演信息
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Director")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(movie.director)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
        }
        .ignoresSafeArea(edges: .top)
        // iOS 18+ 风格：动态网格背景
        .background {
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1),
                    ],
                    colors: [
                        .blue.opacity(0.1), .purple.opacity(0.1), .blue.opacity(0.1),
                        .indigo.opacity(0.1), .white, .indigo.opacity(0.1),
                        .blue.opacity(0.1), .purple.opacity(0.1), .blue.opacity(0.1),
                    ]
                )
                .ignoresSafeArea()
            } else {
                Color(uiColor: .systemBackground)
            }
        }
    }
}