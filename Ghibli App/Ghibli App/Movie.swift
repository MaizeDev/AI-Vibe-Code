//
//  Movie.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//

import SwiftData
import Foundation

/// 电影数据模型，用于表示吉卜力电影的信息
struct Movie: Codable, Identifiable, Sendable, Hashable {
    /// 电影唯一标识符
    let id: String
    /// 电影标题
    let title: String
    /// 电影原始标题
    let originalTitle: String
    /// 电影海报图片URL
    let image: String
    /// 电影横幅图片URL
    let movieBanner: String
    /// 电影描述
    let description: String
    /// 电影导演
    let director: String
    /// 发布日期
    let releaseDate: String
    /// 运行时间（分钟）
    let runningTime: String
    /// RT评分
    let rtScore: String

    /// JSON解码键值映射
    enum CodingKeys: String, CodingKey {
        case id, title, image, description, director
        case originalTitle = "original_title"
        case movieBanner = "movie_banner"
        case releaseDate = "release_date"
        case runningTime = "running_time"
        case rtScore = "rt_score"
    }
}

/// 持久化模型 - SwiftData
/// 用于存储用户的收藏列表
@Model
final class FavoriteMovie {
    /// 电影唯一标识符（唯一属性）
    @Attribute(.unique) var id: String
    /// 电影标题
    var title: String
    /// 电影海报图片URL
    var image: String
    /// 电影描述
    var desc: String
    /// 收藏时间戳
    var timestamp: Date

    /// 从Movie对象创建FavoriteMovie实例
    /// - Parameter movie: 来源Movie对象
    init(from movie: Movie) {
        id = movie.id
        title = movie.title
        image = movie.image
        desc = movie.description
        timestamp = Date()
    }
}