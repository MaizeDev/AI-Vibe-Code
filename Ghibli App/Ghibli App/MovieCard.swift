//
//  MovieCard.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI

/// 电影卡片组件，展示单部电影的简要信息
struct MovieCard: View {
    /// 要展示的电影数据
    let movie: Movie
    /// 电影是否已收藏
    let isFavorite: Bool
    /// 切换收藏状态的回调函数
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 智能海报加载
            AsyncImage(url: URL(string: movie.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.gray.opacity(0.3)
                        .overlay(Image(systemName: "film").foregroundStyle(.secondary))
                } else {
                    Color.gray.opacity(0.1)
                        .overlay(ProgressView())
                }
            }
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

            // 内容区域
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(movie.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer()

                    // 收藏按钮 (带触觉反馈)
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isFavorite ? .pink : .gray.opacity(0.5))
                            .symbolEffect(.bounce, value: isFavorite) // 弹跳动画
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }

                Text(movie.releaseDate)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())

                Text(movie.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        // 滚动视觉差效果
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}