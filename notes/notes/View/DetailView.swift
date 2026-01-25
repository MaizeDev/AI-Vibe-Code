// DetailView.swift

import SwiftUI
import SwiftData

struct DetailView: View {
    let note: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 按 index 排序显示
                ForEach(note.blocks.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.id) { block in
                    if block.type == .text {
                        if let text = block.textContent, !text.isEmpty {
                            Text(text)
                                .font(.body)
                                .lineSpacing(6) // 增加行间距，阅读体验更好
                        }
                    } else if block.type == .image, let data = block.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit() // 保持比例，宽度自适应
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 底部日期
                Text(note.creationDate.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
