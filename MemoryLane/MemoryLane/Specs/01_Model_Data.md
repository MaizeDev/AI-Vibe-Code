# SPEC: 01_Model_Data
# ROLE: @Architect

## 目标
构建应用的数据基础，确保 UI 层有丰富、真实的模拟数据可供展示。

## 需求详情

1.  **Models (`DiaryEntry`)**:
    -   创建一个符合 `Identifiable`, `Codable`, `Sendable` 的结构体 `DiaryEntry`。
    -   属性包含：
        -   `id`: UUID
        -   `content`: String (日记文本)
        -   `images`: [URL] (图片链接数组，0-9张)
        -   `createdAt`: Date (发布时间)
        -   `location`: String? (可选，地理位置)
        -   `isFavorite`: Bool (是否收藏)

2.  **Mock Data Service**:
    -   创建一个 `MockDataService` 单例或注入类。
    -   生成至少 20 条模拟数据。
    -   **数据要求**：
        -   时间跨度：覆盖过去一年。
        -   内容长度：长短不一，有的只有一句话，有的有三段话。
        -   图片数量：覆盖 0 张, 1 张, 2 张, 4 张, 9 张的情况。
        -   图片源：使用 Unsplash Source 或类似的高质量随机图片 URL。

3.  **Swift 6 Concurrency**:
    -   确保数据获取方法是 `async/await` 的，或者使用 `@MainActor` 标注 ViewModel 以确保 UI 更新安全。

## 输出要求
- 提供 `DiaryEntry.swift`
- 提供 `MockDataService.swift`
