//
//  NoteCardView.swift
//  notes
//
//  Created by wheat on 1/22/26.
//

import SwiftData
import SwiftUI

// 假设的 Note 模型 (为了让代码可编译，补充在这里)
// @Model
// class Note { ... }

struct NoteCardView: View {
    @Environment(\.modelContext) private var modelContext
    let note: Note

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // MARK: - Avatar

                Circle()
                    .fill(Color.blue.gradient) // 加上渐变稍微好看点
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )

                // MARK: - Content Column

                VStack(alignment: .leading, spacing: 8) {
                    // Header
                    HStack(spacing: 6) {
                        Text("用户")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("· \(NoteDateFormatter.shared.format(note.creationDate))") // 优化点1
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        // 优化点2: 使用 Menu 替代 Button + ContextMenu
                        Menu {
                            Button(role: .destructive) {
                                deleteNote()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18)) // 稍微调大一点点方便点击
                                .padding(8) // 增加点击热区
                                .foregroundStyle(.secondary)
                                .contentShape(Rectangle()) // 确保点击区域是正方形，不是只有线条
                        }
                        .buttonStyle(.borderless) // ⭐️⭐️⭐️ 关键修复：加上这一行
                        // .buttonStyle(.plain)   // 如果 borderless 不行，尝试用 plain
                    }

                    // MARK: - ⚠️ 修改点：使用 previewContent

                    if !note.previewContent.isEmpty {
                        // 使用你之前的 CollapsibleText 或普通 Text
                        Text(note.previewContent)
                            .font(.body)
                            .lineLimit(5) // 朋友圈风格限制行数
                    }

                    // MARK: - ⚠️ 修改点：使用 previewImages

                    if !note.previewImages.isEmpty {
                        // 使用你现有的 MediaGridView
                        MediaGridView(imageData: note.previewImages)
                            .padding(.top, 4)
                    }

                    // Action bar
                    HStack {
                        actionButton(icon: "bubble.left")
                        Spacer()
                        actionButton(icon: "arrow.2.squarepath")
                        Spacer()
                        actionButton(
                            icon: note.isFavorite ? "heart.fill" : "heart",
                            active: note.isFavorite
                        ) {
                            toggleFavorite()
                        }
                        Spacer()
                        actionButton(icon: "square.and.arrow.up")
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
            }
            .padding(.horizontal, 16)
//            .padding(.vertical, 12)

            Divider()
                .padding(.leading, 68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Logic

    private func deleteNote() {
        withAnimation {
            modelContext.delete(note)
            // SwiftData 会自动保存，通常不需要手动 save，除非需要立即处理错误
        }
    }

    private func toggleFavorite() {
        // 添加一个轻微的触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            note.isFavorite.toggle()
        }
    }

    // MARK: - Action Button

    private func actionButton(
        icon: String,
        active: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18)) // 统一图标大小
                .foregroundColor(active ? .red : .secondary)
                .padding(8) // 优化点4: 扩大点击热区
                .contentShape(Rectangle()) // 确保透明区域也能点击
        }
        .buttonStyle(.plain)
    }
}

// 优化点1: 静态 Formatter 提升性能
struct NoteDateFormatter {
    static let shared = NoteDateFormatter()
    private let formatter = DateFormatter()
    private let calendar = Calendar.current

    private init() {}

    func format(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
}

// 优化点3: 响应式 Grid，移除硬编码高度
// 修复后的图片网格视图
struct MediaGridView: View {
    let imageData: [Data]

    // 定义：3列布局 (适用于 2, 3, 5, 6, 7, 8, 9 张图)
    private let threeColumnGrid = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]

    // 定义：2列布局 (专门用于 4 张图，显示为田字格)
    private let twoColumnGrid = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]

    var body: some View {
        Group {
            if imageData.count == 1 {
                // MARK: - 单张图模式

                // 限制最大高度，防止长图占满屏幕
                mediaImage(imageData[0])
                    .aspectRatio(contentMode: .fill) // 填充
                    .frame(maxHeight: 250) // 限制单张图最大高度
                    .frame(maxWidth: .infinity, alignment: .leading) // 左对齐，不强制撑满宽
                    .cornerRadius(12)
                    .clipped()

            } else if imageData.count == 4 {
                // MARK: - 4张图模式 (田字格 2x2)

                LazyVGrid(columns: twoColumnGrid, spacing: 4) {
                    ForEach(imageData.prefix(4).indices, id: \.self) { index in
                        SquareImage(data: imageData[index])
                    }
                }
                .cornerRadius(12)
                // 限制整体网格的宽度，防止4张图时太大 (可选，模仿微信通常会窄一点)
//                .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                // 新代码 (iOS 17+ 推荐)
                .containerRelativeFrame(.horizontal) { length, _ in
                    length * 0.7
                }

            } else {
                // MARK: - 其他数量 (九宫格 3x3)

                // 适用于 2, 3, 5-9 张
                LazyVGrid(columns: threeColumnGrid, spacing: 4) {
                    ForEach(imageData.prefix(9).indices, id: \.self) { index in
                        SquareImage(data: imageData[index])
                    }
                }
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private func mediaImage(_ data: Data) -> some View {
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable() // ⚠️ 关键：允许图片缩放
                .scaledToFill()
        } else {
            Color.gray.opacity(0.1)
        }
    }
}

// 辅助视图：强制正方形图片 (解决对齐问题的关键)
struct SquareImage: View {
    let data: Data

    var body: some View {
        GeometryReader { geo in
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height) // 填满正方形格
                    .clipped() // 裁剪多余部分
                    .contentShape(Rectangle())
            } else {
                Color.secondary.opacity(0.2)
            }
        }
        .aspectRatio(1, contentMode: .fit) // ⚠️ 强制自身比例为 1:1 (正方形)
    }
}


