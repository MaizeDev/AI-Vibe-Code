//
//  AITranction.swift
//  ExpenseTrackerTutorial
//
//  Created by wheat on 2/2/26.
//

import Foundation
import SwiftData
import SwiftUI

// 定义一个结构体 AITransaction，它遵循 Identifiable 协议，以便在 SwiftUI 列表中唯一标识每个交易。
@Model
class AITransaction: Identifiable {
    var id: UUID // 唯一标识符
    var amount: Double // 交易金额
    var date: Date // 交易日期
    var merchant: String // 商户名称
    var category: Category // 交易类别
    var isSubscription: Bool // 是否为订阅
    var notes: String? // 备注，可选

    init(id: UUID, amount: Double, date: Date, merchant: String, category: Category, isSubscription: Bool, notes: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.merchant = merchant
        self.category = category
        self.isSubscription = isSubscription
        self.notes = notes
    }

    // 定义交易类别的枚举，遵循 String、Codable、CaseIterable 和 Identifiable 协议。
    enum Category: String, Codable, CaseIterable, Identifiable {
        case groceries // 食品杂货
        case dining // 外出就餐
        case transport // 交通
        case shopping // 购物
        case entertainment // 娱乐
        case utilities // 水电费
        case health // 健康
        case travel // 旅行
        case subscriptions // 订阅
        case other // 其他

        var id: String { rawValue } // 实现 Identifiable 协议，使用原始值作为唯一标识。

        // 返回易于阅读的类别显示名称。
        var displayName: String {
            switch self {
            case .groceries: return "食品杂货"
            case .dining: return "外出就餐"
            case .transport: return "交通"
            case .shopping: return "购物"
            case .entertainment: return "娱乐"
            case .utilities: return "水电费"
            case .health: return "健康"
            case .travel: return "旅行"
            case .subscriptions: return "订阅"
            case .other: return "其他"
            }
        }

        // 返回与每个类别相关的图标符号和颜色。
        var iconInfo: (symbol: String, color: Color) {
            switch self {
            case .groceries: return ("cart.fill", .green)
            case .dining: return ("fork.knife.circle.fill", .orange)
            case .transport: return ("car.fill", .blue)
            case .shopping: return ("bag.fill", .purple)
            case .entertainment: return ("film.fill", .pink)
            case .utilities: return ("bolt.fill", .yellow)
            case .health: return ("heart.fill", .red)
            case .travel: return ("airplane", .teal)
            case .subscriptions: return ("repeat.circle.fill", .indigo)
            case .other: return ("ellipsis.circle.fill", .gray)
            }
        }
    }

    // 静态工厂方法，用于创建 AITransaction 实例。
    static func make(
        id: UUID = UUID(), amount: Double, daysAgo: Int, merchant: String, category: Category,
        isSubscription: Bool = false, notes: String? = nil
    ) -> AITransaction {
        AITransaction(
            id: id,
            amount: amount,
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(), // 根据 daysAgo 计算日期
            merchant: merchant,
            category: category,
            isSubscription: isSubscription,
            notes: notes
        )
    }

    // 提供一个静态的模拟交易数据，用于预览和测试。
    static var moke: AITransaction {
        AITransaction.make(
            amount: 150.00, daysAgo: 2, merchant: "Apple Store", category: .shopping,
            notes: "新 iPhone 手机壳")
    }

    // 提供一个静态的模拟交易数据数组。
    static var moks: [AITransaction] {
        [
            .make(amount: 12.50, daysAgo: 1, merchant: "星巴克", category: .dining),
            .make(amount: 55.00, daysAgo: 0, merchant: "壳牌", category: .transport, notes: "加油"),
            .make(amount: 9.99, daysAgo: 30, merchant: "Netflix", category: .subscriptions, isSubscription: true),
            .make(amount: 75.00, daysAgo: 5, merchant: "沃尔玛", category: .groceries),
            .make(amount: 2500.00, daysAgo: 10, merchant: "联合航空", category: .travel, notes: "飞往夏威夷的航班"),
            .make(amount: 25.00, daysAgo: 3, merchant: "AMC 影院", category: .entertainment),
            .make(amount: 120.00, daysAgo: 7, merchant: "医生办公室", category: .health, notes: "年度体检"),
            .make(amount: 65.00, daysAgo: 4, merchant: "Comcast", category: .utilities, isSubscription: true),
            .make(amount: 35.00, daysAgo: 6, merchant: "本地餐厅", category: .dining, notes: "与朋友共进晚餐"),
            .make(amount: 55.00, daysAgo: 0, merchant: "壳牌", category: .transport, notes: "加油"),
            .make(amount: 9.99, daysAgo: 30, merchant: "Netflix", category: .subscriptions, isSubscription: true),
            .make(amount: 75.00, daysAgo: 5, merchant: "沃尔玛", category: .groceries),
            .make(amount: 2500.00, daysAgo: 10, merchant: "联合航空", category: .travel, notes: "飞往夏威夷的航班"),
            .make(amount: 25.00, daysAgo: 3, merchant: "AMC 影院", category: .entertainment),
            .make(amount: 120.00, daysAgo: 7, merchant: "医生办公室", category: .health, notes: "年度体检"),
            .make(amount: 65.00, daysAgo: 4, merchant: "Comcast", category: .utilities, isSubscription: true),
            .make(amount: 35.00, daysAgo: 6, merchant: "本地餐厅", category: .dining, notes: "与朋友共进晚餐"),
        ]
    }
}
