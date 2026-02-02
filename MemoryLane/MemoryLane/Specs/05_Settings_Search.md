# SPEC: 05_Settings_Search
# ROLE: @Engineer

## 目标
完善 App 的工具属性，增加付费点（Pro 功能展示）和实用功能。

## 需求详情

1.  **Search (搜索)**:
    -   使用 `.searchable` 修饰符。
    -   支持按日记文本内容关键词搜索。
    -   搜索结果实时展示，复用 `DiaryCardView` 但高亮关键词（可选）。
    -   空状态设计：当没有搜索结果时，显示一个可爱的插画。

2.  **Settings (设置 - Pro Max 风格)**:
    -   使用 `List` 或 `Form`，但需自定义 Section Header 和 Cell 样式，去除默认的灰色背景，使用更现代的白色/深色卡片风格。
    -   **模块规划**:
        -   **Account**: 用户头像（模拟），昵称，"升级到 Pro" 的金卡样式 Banner。
        -   **Security (Pro)**:
            -   FaceID / TouchID 开关 (仅做 UI 和简单的 LocalAuthentication 逻辑)。
            -   "应用锁" 设置。
        -   **Data**:
            -   iCloud 同步 (Toggle)。
            -   导出数据 (CSV/PDF)。
        -   **Appearance**:
            -   主题切换 (跟随系统/深色/浅色)。
            -   更换 App 图标 (列出几个预设图标)。
        -   **About**: 版本号 (v1.0.0)，隐私协议，去评分。

## 输出要求
- 提供 `SearchView.swift`
- 提供 `SettingsView.swift`
