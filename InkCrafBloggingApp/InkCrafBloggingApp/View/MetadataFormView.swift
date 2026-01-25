import SwiftUI

struct MetadataFormView: View {
    @Binding var metadata: PostMetadata
    @Binding var isExpanded: Bool
    
    @State private var dateObj: Date = Date()
    
    // ✅ 关键修复：统一的格式化器
    private var blogDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current // 强制使用本地时区
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // --- 顶部栏 ---
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
                .background(Color.systemBackground)
            }
            .buttonStyle(.plain)
            
            // --- 折叠区域 ---
            if isExpanded {
                VStack(spacing: 16) {
                    // 标题
                    HStack {
                        Text("标题")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                        TextField("文章标题", text: $metadata.title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // 日期
                    HStack {
                        Text("日期")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                        
                        // ✅ 修改：DatePicker
                        DatePicker("", selection: $dateObj, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .onChange(of: dateObj) { _, newValue in
                                // 写入时使用 format
                                metadata.date = blogDateFormatter.string(from: newValue)
                            }
                        Spacer()
                    }
                    
                    // Draft 开关
                    Toggle(isOn: $metadata.draft) {
                        Text("草稿 (Draft)")
                            .foregroundStyle(.secondary)
                    }
                    
                    // Tags
                    HStack(alignment: .top) {
                        Text("标签")
                            .frame(width: 50, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                        
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
                    // ✅ 修改：读取时的兼容逻辑
                    parseDateString()
                }
            }
        }
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func parseDateString() {
        guard !metadata.date.isEmpty else {
            // 如果日期为空，初始化为当前时间
            let now = Date()
            dateObj = now
            metadata.date = blogDateFormatter.string(from: now)
            return
        }
        
        // 1. 尝试标准格式 (yyyy-MM-dd HH:mm:ss)
        if let d = blogDateFormatter.date(from: metadata.date) {
            dateObj = d
            return
        }
        
        // 2. 尝试 ISO8601 (兼容旧数据)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: metadata.date) {
            dateObj = d
            // 修正：读取旧格式后，立即转为新格式保存回去，保持统一
            metadata.date = blogDateFormatter.string(from: d)
            return
        }
        
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: metadata.date) {
            dateObj = d
            metadata.date = blogDateFormatter.string(from: d)
            return
        }
    }
}

extension Color {
    static let systemBackground = Color(uiColor: .systemBackground)
}
