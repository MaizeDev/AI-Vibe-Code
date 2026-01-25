//
//  NoteModels.swift
//  notes
//
//  Created by wheat on 1/24/26.
//

import Foundation
import SwiftData
import SwiftUI

// 定义块的类型
enum BlockType: String, Codable {
    case text
    case image
}

@Model
final class NoteBlock {
    var id: UUID
    var orderIndex: Int
    var type: BlockType
    var textContent: String?
    @Attribute(.externalStorage) var imageData: Data?

    var note: Note?

    init(orderIndex: Int, type: BlockType, textContent: String? = nil, imageData: Data? = nil) {
        id = UUID()
        self.orderIndex = orderIndex
        self.type = type
        self.textContent = textContent
        self.imageData = imageData
    }
}

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var creationDate: Date
    var isFavorite: Bool

    @Relationship(deleteRule: .cascade, inverse: \NoteBlock.note)
    var blocks: [NoteBlock] = []

    init(creationDate: Date = Date(), isFavorite: Bool = false) {
        id = UUID()
        self.creationDate = creationDate
        self.isFavorite = isFavorite
    }

    // MARK: - Helpers

    var previewContent: String {
        blocks.sorted { $0.orderIndex < $1.orderIndex }
            .compactMap { $0.textContent }
            .joined(separator: "\n")
    }

    var previewImages: [Data] {
        blocks.sorted { $0.orderIndex < $1.orderIndex }
            .compactMap { $0.imageData }
            .prefix(9)
            .map { $0 }
    }

    // 全文搜索辅助
    var fullText: String {
        blocks.compactMap { $0.textContent }.joined(separator: " ")
    }
}

// MARK: - 预览数据 (修复版)

extension Note {
    static var sampleData: [Note] {
        // 笔记 1：图文混排
        let note1 = Note(isFavorite: true)
        note1.blocks = [
            NoteBlock(orderIndex: 0, type: .text, textContent: "今天天气真不错，去公园散步时看到了一只非常可爱的小猫。"),
            NoteBlock(orderIndex: 1, type: .image, imageData: UIImage(systemName: "cat.fill")?.withTintColor(.orange).pngData()),
            NoteBlock(orderIndex: 2, type: .text, textContent: "它一点都不怕人，还过来蹭我的裤腿。"),
            NoteBlock(orderIndex: 3, type: .image, imageData: UIImage(systemName: "tree.fill")?.withTintColor(.green).pngData()),
        ]

        // 笔记 2：纯文字
        let note2 = Note(isFavorite: false)
        note2.blocks = [
            NoteBlock(orderIndex: 0, type: .text, textContent: "SwiftData 的 Relationship 配置真的很重要！一定要记得设置 deleteRule: .cascade，否则删除笔记时，里面的图片块数据还会残留在数据库里。"),
        ]

        // 笔记 3：多图展示
        let note3 = Note(isFavorite: true)
        note3.blocks = [
            NoteBlock(orderIndex: 0, type: .text, textContent: "最近收集的一些设计素材："),
            NoteBlock(orderIndex: 1, type: .image, imageData: UIImage(systemName: "star.fill")?.pngData()),
            NoteBlock(orderIndex: 2, type: .image, imageData: UIImage(systemName: "heart.fill")?.pngData()),
            NoteBlock(orderIndex: 3, type: .image, imageData: UIImage(systemName: "bolt.fill")?.pngData()),
            NoteBlock(orderIndex: 4, type: .image, imageData: UIImage(systemName: "moon.fill")?.pngData()),
        ]

        return [note1, note2, note3]
    }
}

// 确保预览容器加载数据
extension ModelContainer {
    static var preview: ModelContainer {
        let schema = Schema([Note.self, NoteBlock.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)

        if try! container.mainContext.fetch(FetchDescriptor<Note>()).isEmpty {
            for note in Note.sampleData {
                container.mainContext.insert(note)
            }
        }
        return container
    }
}
