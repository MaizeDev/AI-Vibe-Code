import Foundation
import SwiftUI
import UniformTypeIdentifiers // 必须引用这个

@Observable
class WorkspaceManager {
    var rootFolder: FileSystemItem?
    var selectedFile: FileSystemItem?
    var errorMessage: String?
    
    // 用于存储权限书签的 Key
    private let bookmarkKey = "InkCraftLastOpenedFolder"
    
    init() {
        // App 启动时，尝试恢复上次打开的文件夹
        restoreLastOpenedFolder()
    }
    
    // MARK: - 统一处理选择的 URL (核心逻辑)
    @MainActor // 确保在主线程更新 UI
    func handleSelectedURL(_ url: URL) {
        var targetFolderURL: URL
        var fileToSelect: URL? = nil
        
        // 判断用户选的是文件还是文件夹
        if url.hasDirectoryPath {
            targetFolderURL = url
        } else {
            // 如果选的是文件，就获取它的父级文件夹作为根目录
            targetFolderURL = url.deletingLastPathComponent()
            fileToSelect = url
        }
        
        // 1. 获取权限并保存书签 (下次重启能记住)
        if saveBookmark(for: targetFolderURL) {
            // 2. 打开文件夹
            openFolder(at: targetFolderURL)
            
            // 3. 如果选的是文件，自动选中它
            if let fileURL = fileToSelect {
                // 简单的查找逻辑：在第一层子项里找
                if let foundItem = rootFolder?.children?.first(where: { $0.url.path == fileURL.path }) {
                    selectedFile = foundItem
                }
            }
        }
    }
    
    // MARK: - 打开文件夹逻辑
    @MainActor
    func openFolder(at url: URL) {
        // 这里的 startAccessing... 是针对本次运行的
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "无法访问该文件夹权限"
            return
        }
        // 注意：不在这里调用 stopAccessing，因为我们需要持续访问
        // 实际项目中应该管理好 scope 的生命周期
        
        do {
            let items = try loadContents(of: url)
            self.rootFolder = FileSystemItem(url: url, isDirectory: true, children: items)
            self.errorMessage = nil // 清除错误
        } catch {
            errorMessage = "读取失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 递归读取文件
    private func loadContents(of url: URL) throws -> [FileSystemItem] {
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        
        let contentURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: options)
        
        var items: [FileSystemItem] = []
        
        for fileURL in contentURLs {
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            
            if isDir.boolValue {
                let children = (try? loadContents(of: fileURL)) ?? []
                items.append(FileSystemItem(url: fileURL, isDirectory: true, children: children))
            } else {
                // 宽松判断：只要是 md 或 markdown 结尾，或者 txt
                let ext = fileURL.pathExtension.lowercased()
                if ["md", "markdown", "txt"].contains(ext) {
                    items.append(FileSystemItem(url: fileURL, isDirectory: false))
                }
            }
        }
        
        return items.sorted {
            ($0.isDirectory && !$1.isDirectory) || ($0.name < $1.name)
        }
    }
    
    // MARK: - 生成测试数据
    @MainActor
    func generateSampleFiles() {
        let fileManager = FileManager.default
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let blogURL = docURL.appendingPathComponent("MyBlog_Debug")
        
        // ... (保持你之前的生成代码不变，略) ...
        // 这里的逻辑可以复用你之前写的，或者简化如下：
        
        do {
            if !fileManager.fileExists(atPath: blogURL.path) {
                try fileManager.createDirectory(at: blogURL, withIntermediateDirectories: true)
            }
            
            let welcomeFile = blogURL.appendingPathComponent("welcome.md")
            if !fileManager.fileExists(atPath: welcomeFile.path) {
                try "# Hello Mock Data".write(to: welcomeFile, atomically: true, encoding: .utf8)
            }
            
            // 生成完直接打开
            openFolder(at: blogURL)
            print("Mock 数据已生成并打开")
            
        } catch {
            print("生成失败: \(error)")
        }
    }

    // MARK: - 权限持久化 (Bookmark)
    
    private func saveBookmark(for url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else { return false }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            return true
        } catch {
            print("保存书签失败: \(error)")
            return false
        }
    }
    
    private func restoreLastOpenedFolder() {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return }
        
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
            
            if isStale {
                // 如果书签过期（比如文件被移动了），重新保存一下（这里简化处理）
                _ = saveBookmark(for: url)
            }
            
            // 恢复访问权限并打开
            if url.startAccessingSecurityScopedResource() {
                // 注意：这里需要切换到主线程更新 UI，因为 init 是在后台可能被调用
                Task { @MainActor in
                    self.openFolder(at: url)
                }
            }
        } catch {
            print("无法恢复上次打开的文件夹: \(error)")
        }
    }
}
