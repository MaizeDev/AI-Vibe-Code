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
