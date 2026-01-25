import Foundation
import SwiftUI

@Observable
class WorkspaceManager {
    var rootFolder: FileSystemItem?
    var selectedFile: FileSystemItem?
    var errorMessage: String?
    
    // MARK: - 打开文件夹 (入口)
    func openFolder(at url: URL) {
        // 1. 获取安全访问权限
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "无法访问该文件夹，请检查权限。"
            return
        }
        
        // 注意：在实际项目中，你需要保存 url 的 bookmarkData 以便下次自动打开
        // 这里简化处理，仅做当次读取
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        // 2. 加载文件树
        do {
            let items = try loadContents(of: url)
            self.rootFolder = FileSystemItem(url: url, isDirectory: true, children: items)
        } catch {
            errorMessage = "读取失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 递归读取文件
    private func loadContents(of url: URL) -> [FileSystemItem] {
        let fileManager = FileManager.default
        // 配置读取选项：不包含隐藏文件
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        
        guard let contentURLs = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: options) else {
            return []
        }
        
        var items: [FileSystemItem] = []
        
        for fileURL in contentURLs {
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            
            if isDir.boolValue {
                // 如果是文件夹，递归读取 (注意：实际开发中可能需要懒加载以优化性能)
                let children = loadContents(of: fileURL)
                items.append(FileSystemItem(url: fileURL, isDirectory: true, children: children))
            } else {
                // 只加载 Markdown 文件
                if fileURL.pathExtension.lowercased() == "md" {
                    items.append(FileSystemItem(url: fileURL, isDirectory: false))
                }
            }
        }
        
        // 排序：文件夹在前，文件在后
        return items.sorted {
            ($0.isDirectory && !$1.isDirectory) || ($0.name < $1.name)
        }
    }
}