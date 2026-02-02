# SPEC: 03_Home_Timeline
# ROLE: @Engineer + @Designer

## 目标
实现核心功能：像刷朋友圈一样查看日记。

## 需求详情

1.  **Timeline Layout (时间轴)**:
    -   使用 `ScrollView` + `LazyVStack`。
    -   每个 Cell (`DiaryCardView`) 代表一篇日记。

2.  **Diary Card Design ($ui-ux-pro-max)**:
    -   **Header**: 左侧显示日期（大号字体显示 "日"，小号显示 "月/年"），或者采用相对时间（如 "2小时前"）。
    -   **Content**: 文本内容，限制最多显示 5 行，超过显示 "全文" 按钮（可选）。
    -   **Image Grid (重点)**:
        -   使用 Nuke (`LazyImage`) 加载图片。
        -   **布局逻辑**：
            -   1 张图：显示大图，圆角，比例 16:9 或 4:3。
            -   2 张图：双列等宽。
            -   3 张图：三列等宽。
            -   4 张图：田字格 (2x2)。
            -   更多图片：九宫格布局。
        -   图片需支持点击预览（暂时不做复杂的转场，先做点击放大或 Sheet 弹窗）。
    -   **Footer**: 显示具体时间 (YYYY-MM-dd HH:mm:ss)，位置图标，以及 "更多" 按钮（三个点）。

3.  **Interactions**:
    -   下拉刷新 (Pull to Refresh)。
    -   滚动时导航栏背景渐变效果 (Glassmorphism)。

## 输出要求
- 提供 `DiaryCardView.swift`
- 提供 `ImageGridView.swift` (处理不同数量图片的布局)
- 提供 `HomeView.swift`
