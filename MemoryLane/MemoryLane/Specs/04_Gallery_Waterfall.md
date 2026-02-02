# SPEC: 04_Gallery_Waterfall
# ROLE: @Designer

## 目标
以视觉优先的方式展示所有历史图片，打造沉浸式回忆体验。

## 需求详情

1.  **Data Preparation**:
    -   从所有日记中提取出包含图片的条目，打平成一个图片数组。

2.  **Waterfall Layout (双列瀑布流)**:
    -   由于 iOS 16 原生 `LazyVGrid` 是固定行高/列宽，无法完美实现交错瀑布流。
    -   **方案**: 使用 `HStack` 包含两个 `LazyVStack`。将图片数据按索引奇偶数分配给左右两列。
    -   每张图片卡片显示：
        -   图片本身 (Nuke `LazyImage`, contentMode: .fill)。
        -   圆角 12px。
        -   右下角微小的时间标签。

3.  **Navigation**:
    -   点击图片跳转到该图片所属的日记详情页（复用 `DiaryCardView` 或新建 `DiaryDetailView`）。

## 输出要求
- 提供 `GalleryView.swift`
- 提供 `WaterfallLayout.swift` (或逻辑实现)
