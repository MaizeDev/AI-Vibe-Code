import SwiftUI

struct MetadataFormView: View {
    @Binding var metadata: PostMetadata
    @Binding var isExpanded: Bool // 控制折叠/展开
    
    // 临时的 Date 对象，用于绑定 DatePicker
    @State private var dateObj: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // --- 顶部栏 (点击折叠/展开) ---
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "doc.text.image")
                        .foregroundStyle(.blue)
                    Text("文章属性")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .background(Color.systemBackground) // 确保点击区域完整
            }
            .buttonStyle(.plain)
            
            // --- 折叠区域 ---
            if isExpanded {
                VStack(spacing: 16) {
                    // 1. 标题
                    HStack {
                        Text("标题")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                        TextField("文章标题", text: $metadata.title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // 2. 日期
                    HStack {
                        Text("日期")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                        DatePicker("", selection: $dateObj, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .onChange(of: dateObj) { _, newValue in
                                // 将 Date 转回 String (格式 ISO8601)
                                let formatter = ISO8601DateFormatter()
                                formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
                                metadata.date = formatter.string(from: newValue)
                            }
                        Spacer()
                    }
                    
                    // 3. Draft 开关
                    Toggle(isOn: $metadata.draft) {
                        Text("草稿 (Draft)")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 4. 简易 Tags 编辑 (逗号分隔)
                    HStack(alignment: .top) {
                        Text("标签")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                        
                        // 这里用一个 Binding 转换，把 ["iOS", "Swift"] 转成 "iOS, Swift"
                        TextField("Swift, iOS (逗号分隔)", text: Binding(
                            get: { metadata.tags.joined(separator: ", ") },
                            set: { newValue in
                                metadata.tags = newValue
                                    .split(separator: ",")
                                    .map { String($0).trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.bottom, 8)
                .onAppear {
                    // 初始化日期
                    // 简单的尝试解析逻辑
                    let formatter = ISO8601DateFormatter()
                    if let d = formatter.date(from: metadata.date) {
                        dateObj = d
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// 辅助扩展：为了适配颜色
extension Color {
    static let systemBackground = Color(uiColor: .systemBackground)
}