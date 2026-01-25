//
//  ContentView.swift
//  InkCrafBloggingApp
//
//  Created by wheat on 1/25/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var workspace = WorkspaceManager()
    @State private var showFileImporter = false

    // 新增：用于存储当前正在编辑的文本内容
    @State private var documentContent: String = ""
    // --- 新增状态 ---
    @State private var metadata = PostMetadata() // 存储解析后的头信息
    @State private var bodyContent: String = "" // 存储正文
    @State private var isMetadataExpanded = true // 控制表单折叠
    @State private var isInternalUpdate = false // 防止死循环的锁
    
    @State private var showPreview = false

    var body: some View {
        NavigationSplitView {
            // --- 侧边栏 ---
            VStack {
                if let root = workspace.rootFolder {
                    List(root.children ?? [], id: \.self, selection: $workspace.selectedFile) { item in
                        // 修改：点击导航链接
                        NavigationLink(value: item) {
                            Label(item.name, systemImage: item.isDirectory ? "folder" : "doc.text")
                        }
                    }
                } else {
                    ContentUnavailableView("未打开博客", systemImage: "folder.badge.gear", description: Text("请选择你的 Hugo/Hexo 根目录"))
                    Button("打开文件夹") {
                        showFileImporter = true
                    }
                    .padding()
                    .buttonStyle(.borderedProminent) // 加个样式

                    // 👇 新增这个按钮
                    Button("🛠️ 生成并打开测试数据") {
                        workspace.generateSampleFiles()
                    }
                    .padding(.top)
                    .tint(.orange) // 搞个橙色区分一下
                }
            }
            .navigationTitle("资源管理器")

        } detail: {
            if let selected = workspace.selectedFile, !selected.isDirectory {
                VStack(spacing: 0) {
                    // 元数据表单 (预览模式下也许可以隐藏，看你喜好)
                    if !showPreview {
                        MetadataFormView(metadata: $metadata, isExpanded: $isMetadataExpanded)
                        // ... onChange ...
                        Divider()
                    }
                    
                    // 核心区域：切换显示
                    if showPreview {
                        MarkdownPreviewView(content: bodyContent)
                    } else {
                        MarkdownEditor(text: $bodyContent)
                        // ... onChange ...
                    }
                }
                .toolbar {
                    // 添加切换按钮
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showPreview.toggle() }) {
                            Image(systemName: showPreview ? "pencil" : "eye")
                        }
                    }
                }
            }
        }
        // --- 文件选择器 ---
        .fileImporter(
            isPresented: $showFileImporter,
            // 关键修改 1: 允许选择 文件夹(.folder) 和 文本文件(.plainText, .markdown)
            allowedContentTypes: [.folder, .plainText, .content],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                // fileImporter 返回的是数组，我们取第一个
                if let url = urls.first {
                    // 关键修改 2: 无论选的是文件还是文件夹，WorkspaceManager 都要能处理
                    workspace.handleSelectedURL(url)
                }
            case let .failure(error):
                print("选择失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 新的读写逻辑

    private func readFile(item: FileSystemItem) {
        let url = item.url
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let fullText = String(data: data, encoding: .utf8) ?? ""

            // 🔒 上锁，避免赋值触发 onChange 导致循环保存
            isInternalUpdate = true

            // 使用引擎拆分
            let (meta, content) = FrontmatterEngine.parse(document: fullText)
            metadata = meta
            bodyContent = content

            // 🔓 解锁 (延迟一点点确保 UI 刷新完毕)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInternalUpdate = false
            }

        } catch {
            print("读取失败: \(error)")
        }
    }

    private func saveCombinedFile(meta: PostMetadata, content: String, to item: FileSystemItem) {
        let url = item.url
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        // 使用引擎重新拼装
        let fullText = FrontmatterEngine.reconstruct(metadata: meta, content: content)

        do {
            try fullText.write(to: url, atomically: true, encoding: .utf8)
            print("自动保存成功")
        } catch {
            print("保存失败: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
