import SwiftUI

struct ContentView: View {
    // 引用 ViewModel (StateObject 保证对象生命周期跟随 View)
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        HSplitView {
            // --- 左侧：编辑器区域 ---
            VStack(alignment: .leading, spacing: 0) {
                HeaderView(title: "Markdown Editor")
                
                MacEditorView(text: $viewModel.markdownText, scrollPercentage: $viewModel.scrollPercentage) // 传入 Binding
                    .onChange(of: viewModel.markdownText) { _, newValue in
                        viewModel.onTextChange(newValue)
                    }
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .textBackgroundColor))
            
            // --- 右侧：预览区域 ---
            VStack(alignment: .leading, spacing: 0) {
                // 右侧工具栏比较复杂，我们就直接写在这里，或者也可以拆分
                HStack {
                    Text("Preview")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 按钮只需调用 ViewModel 的方法
                    Button(action: viewModel.copyHtmlToClipboard) {
                        Image(systemName: "doc.on.doc").font(.caption)
                    }
                    .help("Copy HTML")
                    .buttonStyle(.borderless)
                    .padding(.trailing, 8)
                    
                    Button(action: viewModel.exportHtmlFile) {
                        Image(systemName: "square.and.arrow.up").font(.caption)
                    }
                    .help("Export HTML")
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .windowBackgroundColor))
                
                Divider()
                
                // 使用抽离出去的 WebView
                WebView(html: viewModel.htmlContent, scrollPercentage: viewModel.scrollPercentage) // 传入值
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: viewModel.clearText) {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
    }
}

// 提取一个小组件：标题栏头
// 放在同一个文件里方便调用，因为很短
struct HeaderView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
        }
    }
}

#Preview {
    ContentView()
}
