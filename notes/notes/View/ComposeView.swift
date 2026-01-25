//
//  ComposeView.swift
//  notes
//
//  Created by wheat on 1/24/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditableBlock: Identifiable {
    let id = UUID()
    var type: BlockType
    var text: String = ""
    var image: UIImage? = nil
}

struct ComposeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var blocks: [EditableBlock] = [EditableBlock(type: .text)]
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // 焦点控制
    @FocusState private var focusedFieldID: UUID?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(blocks.indices, id: \.self) { index in
                            let block = blocks[index]
                            
                            if block.type == .text {
                                ZStack(alignment: .topLeading) {
                                    if blocks[index].text.isEmpty {
                                        if index == 0 {
                                            Text("写点什么...")
                                                .foregroundStyle(.tertiary)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 8)
                                        } else {
                                            Text("继续输入...")
                                                .font(.caption)
                                                .foregroundStyle(.quaternary.opacity(0.5))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                    
                                    TextField("", text: $blocks[index].text, axis: .vertical)
                                        .focused($focusedFieldID, equals: block.id) // 绑定焦点
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .lineLimit(nil)
                                }
                                .onTapGesture {
                                    focusedFieldID = block.id
                                }
                            } else {
                                imageBlockView(block: block, index: index)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 60)
                }
                .safeAreaInset(edge: .bottom) {
                    if focusedFieldID != nil {
                        editorToolbar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .onChange(of: blocks.count) { _, _ in
                    if let lastId = blocks.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                // ⭐️ 修复点：进入页面自动激活焦点
                .onAppear {
                    // 稍微延迟一点点，等待转场动画结束，体验更流畅
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // 聚焦到第一个块
                        if let firstId = blocks.first?.id {
                            focusedFieldID = firstId
                        }
                    }
                }
            }
            .navigationTitle("新笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveNote() }
                        .disabled(blocks.allSatisfy { $0.text.isEmpty && $0.image == nil })
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: selectedItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                Task {
                    var images: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            images.append(uiImage)
                        }
                    }
                    
                    await MainActor.run {
                        insertImageBlocks(images)
                        selectedItems = []
                    }
                }
            }
        }
    }
    
    // ... (下面的 imageBlockView, editorToolbar, Logic 代码保持不变，不需要修改) ...
    // 为了完整性，防止你找不到，这里简单列出不需要动的部分占位
    
    private func imageBlockView(block: EditableBlock, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let img = block.image {
                Image(uiImage: img).resizable().scaledToFit().cornerRadius(8).frame(maxHeight: 300).frame(maxWidth: .infinity)
            }
            Button { deleteBlock(at: index) } label: {
                Image(systemName: "xmark.circle.fill").symbolRenderingMode(.palette).foregroundStyle(.white, .black.opacity(0.6)).font(.title2)
            }.padding(8)
        }
    }
    
    private var editorToolbar: some View {
        HStack {
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Image(systemName: "photo").font(.title2).foregroundColor(.blue).frame(width: 44, height: 44)
            }
            Spacer()
            Button { focusedFieldID = nil } label: {
                Image(systemName: "keyboard.chevron.compact.down").font(.title2).foregroundColor(.secondary).frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal).padding(.vertical, 8).background(.regularMaterial)
    }
    
    private func insertImageBlocks(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        var insertIndex = blocks.endIndex
        if let focusedID = focusedFieldID, let idx = blocks.firstIndex(where: { $0.id == focusedID }) {
            insertIndex = idx + 1
        }
        for image in images {
            let imageBlock = EditableBlock(type: .image, image: image)
            blocks.insert(imageBlock, at: insertIndex)
            insertIndex += 1
            let textBlock = EditableBlock(type: .text)
            blocks.insert(textBlock, at: insertIndex)
            insertIndex += 1
            focusedFieldID = textBlock.id
        }
    }
    
    private func deleteBlock(at index: Int) {
        withAnimation {
            blocks.remove(at: index)
            if blocks.isEmpty { blocks.append(EditableBlock(type: .text)) }
        }
    }
    
    private func saveNote() {
        let newNote = Note()
        for (index, block) in blocks.enumerated() {
            if block.type == .text && block.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
            let noteBlock = NoteBlock(
                orderIndex: index,
                type: block.type,
                textContent: block.type == .text ? block.text : nil,
                imageData: block.type == .image ? block.image?.jpegData(compressionQuality: 0.7) : nil
            )
            newNote.blocks.append(noteBlock)
        }
        if !newNote.blocks.isEmpty {
            context.insert(newNote)
            try? context.save()
        }
        dismiss()
    }
}
