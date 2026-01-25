import Foundation
import SwiftUI

struct FileSystemItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let url: URL
    var name: String { url.lastPathComponent }
    var isDirectory: Bool
    var children: [FileSystemItem]? // 如果是文件夹，则有子项
    
    // 简单的初始化器
    init(url: URL, isDirectory: Bool, children: [FileSystemItem]? = nil) {
        self.url = url
        self.isDirectory = isDirectory
        self.children = children
    }
}