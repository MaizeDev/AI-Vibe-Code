## CardView.swift

```swift
import SwiftUI

struct CardView: View {
    let text: String
    let theme: CardTheme
    let author: String
    
    var body: some View {
        ZStack {
            // 背景层
            Rectangle()
                .fill(theme.background)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 装饰性引号
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.textColor.opacity(0.6))
                    Spacer()
                }
                
                // 主要文字内容
                Text(text.isEmpty ? "在此输入文字..." : text)
                    .font(.custom(theme.fontName, size: 22))
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                
                // 底部署名
                HStack {
                    Spacer()
                    Text("— \(author.isEmpty ? "未名" : author)")
                        .font(.custom(theme.fontName, size: 14))
                        .foregroundStyle(theme.textColor.opacity(0.8))
                        .italic()
                    Image(systemName: "quote.closing")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.textColor.opacity(0.6))
                }
                .padding(.top, 10)
            }
            .padding(40)
        }
        .frame(width: 375, height: 375) // 固定宽高比，方便导出正方形图片
        .clipShape(RoundedRectangle(cornerRadius: 0)) // 导出时通常不需要圆角，或者在外部加
    }
}

```

## CardViewModel.swift

```swift
//
//  CardViewModel.swift
//  demo
//
//  Created by wheat on 1/15/26.
//


import SwiftUI
import Photos
import Combine

@MainActor
class CardViewModel: ObservableObject {
    @Published var inputText: String = "生活不是等待风暴过去，而是学会在雨中跳舞。"
    @Published var authorText: String = "Antigravity"
    @Published var selectedTheme: CardTheme = CardTheme.allThemes.first!
    @Published var showSaveSuccessAlert: Bool = false
    @Published var errorMessage: String?
    
    // 生成并保存图片
    func saveImage(view: some View, scale: CGFloat) {
            let renderer = ImageRenderer(content: view)
            
            // 使用传入的 scale，而不是 UIScreen.main.scale
            renderer.scale = scale
            
            if let uiImage = renderer.uiImage {
                saveToAlbum(image: uiImage)
            } else {
                self.errorMessage = "图片渲染失败"
            }
        }
    
    
    // 在 CardViewModel 中添加
    func renderImage(view: some View, scale: CGFloat) -> Image? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    private func saveToAlbum(image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in
                    self?.errorMessage = "没有相册权限，请在设置中开启"
                }
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            Task { @MainActor in
                self?.showSaveSuccessAlert = true
            }
        }
    }
}

```



## ContentView.swift

```swift
//
//  ContentView.swift
//  demo
//
//  Created by wheat on 1/15/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CardViewModel()
    @FocusState private var isInputFocused: Bool

    // 新增：从环境中获取当前屏幕的缩放比例 (1x, 2x, 3x)
    @Environment(\.displayScale) var displayScale

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. 预览区域 (卡片)
                ZStack {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()

                    // 实际显示的卡片预览
                    // 我们在这里复用 CardView，并添加阴影让它看起来像浮起来
                    cardPreview
                        .scaleEffect(0.85) // 稍微缩小一点以适应屏幕
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                }
                .frame(height: 400)
                .onTapGesture {
                    isInputFocused = false // 点击空白处收起键盘
                }

                // 2. 编辑控制区域
                ScrollView {
                    VStack(spacing: 24) {
                        // 文本输入
                        VStack(alignment: .leading) {
                            Text("内容")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $viewModel.inputText)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                                .focused($isInputFocused)
                        }

                        // 署名输入
                        VStack(alignment: .leading) {
                            Text("署名")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("作者名字", text: $viewModel.authorText)
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                                .focused($isInputFocused)
                        }

                        // 主题选择
                        VStack(alignment: .leading) {
                            Text("风格")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(CardTheme.allThemes) { theme in
                                        ThemeButton(theme: theme, isSelected: viewModel.selectedTheme.id == theme.id) {
                                            withAnimation {
                                                viewModel.selectedTheme = theme
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 替换原来的 Button(action: { ... })
                        // 使用 ShareLink (iOS 16+ 新特性)

                        let viewToRender = CardView(
                            text: viewModel.inputText,
                            theme: viewModel.selectedTheme,
                            author: viewModel.authorText
                        )

                        // 这是一个非常现代的写法
                        ShareLink(
                            item: viewModel.renderImage(view: viewToRender, scale: displayScale) ?? Image(systemName: "xmark"),
                            preview: SharePreview("文字卡片", image: viewModel.renderImage(view: viewToRender, scale: displayScale) ?? Image(systemName: "photo"))
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up") // 图标变成向上的箭头（分享）
                                Text("导出 / 分享图片")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }

                    }
                    .padding(20)
                }
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
            }
            .navigationTitle("文字卡片")
            .navigationBarTitleDisplayMode(.inline)
            .alert("保存成功", isPresented: $viewModel.showSaveSuccessAlert) {
                Button("好的", role: .cancel) { }
            }
            .alert("提示", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // 抽取的预览视图组件
    var cardPreview: some View {
        CardView(
            text: viewModel.inputText,
            theme: viewModel.selectedTheme,
            author: viewModel.authorText
        )
        .clipShape(RoundedRectangle(cornerRadius: 16)) // 预览时加个圆角更好看
    }
}

// 辅助组件：主题选择按钮
struct ThemeButton: View {
    let theme: CardTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(theme.background)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.textColor)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

```



## Model.swift

```
、、、、
```

把上面的 header 和 body 的新样式加到你的 index.html 里。

保存后刷新浏览器，试着往下滚页面，看看导航栏是不是一直粘在顶部不动了？

自己调调 padding-top: 100px; 的值（比如改成 120px 或 80px），找到最舒服的高度（避免内容被导航栏盖住）。

（可选）把 header 的背景色改成半透明：background-color: rgba(236, 240, 241, 0.95);，滚页面时会更有层次感。

完成后在 README.md 写一句：“Day 19：导航栏固定在顶部了！滚页面也不怕找不到菜单，好酷～”