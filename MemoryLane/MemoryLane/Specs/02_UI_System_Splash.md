# SPEC: 02_UI_System_Splash
# ROLE: @Designer

## 目标
确立 App 的视觉基调，并实现一个优雅的开屏动画。

## 需求详情

1.  **Design Tokens (Theme)**:
    -   定义 `AppColors`：主色 (Primary)，背景色 (Background - 适配深色模式)，卡片背景色 (Surface)。
    -   定义 `AppFonts`：封装一套基于 `.rounded` 设计的字体修饰符。

2.  **Splash Screen (开屏)**:
    -   **Logo**: 设计一个简单的符号化 Logo (可以使用 SF Symbols，例如 `book.closed.circle.fill` 配合渐变色)。
    -   **Animation**:
        1.  App 启动时，背景纯色。
        2.  Logo 从中心透明度 0 -> 1，并伴随轻微的缩放 (Scale 0.8 -> 1.0)。
        3.  停留 0.8 秒。
        4.  Logo 向上移动并淡出，或者整个页面像门帘一样拉开，露出主页 (`HomeView`)。
    -   **Logic**: 使用 `if isActive` 状态控制 View 的切换。

## 输出要求
- 提供 `Theme.swift` (颜色和字体扩展)
- 提供 `SplashScreen.swift`
- 提供 `ContentView.swift` (包含从 Splash 到 Main 的逻辑)
