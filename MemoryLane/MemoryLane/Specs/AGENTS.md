# PROJECT: MemoryLane (Pro Max Edition)
# DATE: 2026-01-31
# CONTEXT: iOS 26.2.1 (Simulated via iOS 16+ / Swift 6.0)

## 1. MISSION
构建一个类似于 "微博/朋友圈" 形式的精美日记应用。目标是打造一款用户愿意付费的高端 App，强调视觉体验、流畅动画和隐私安全。

## 2. TECH STACK
- **Language**: Swift 6.x (Strict Concurrency Checking enabled).
- **Framework**: SwiftUI (Life Cycle).
- **Minimum OS**: iOS 16.0+.
- **Image Loading**: Nuke (https://github.com/kean/Nuke) - 使用 NukeUI。
- **Architecture**: MVVM + Repository Pattern.
- **Data Source**: Mock Data (In-Memory for now, prepared for SwiftData/CoreData).

## 3. DESIGN SYSTEM ($ui-ux-pro-max)
遵循 "UI-UX-Pro-Max" 极致体验原则：
- **Typography**: 使用系统圆角字体 (Rounded System Font)，标题加粗，正文舒适行高。
- **Colors**: 支持深色模式 (Dark Mode)。主色调建议使用 "Premium Blue" 或 "Elegant Purple"。
- **Layout**: 大留白 (Whitespace)，卡片式设计 (Card Style)，平滑圆角 (Corner Radius 16-24)。
- **Interaction**: 所有的点击必须有触觉反馈 (Haptic Feedback)。页面跳转使用自定义转场或原生流畅导航。
- **Materials**: 适当使用 UltraThinMaterial (毛玻璃效果)。

## 4. AGENTS (ROLES)
在开发过程中，请根据当前任务扮演以下角色：
- **@Architect**: 负责数据模型 (`DiaryModel`)，数据服务 (`DataService`)，以及并发安全 (`@MainActor`, `Sendable`)。
- **@Designer**: 负责 SwiftUI View 的布局，颜色系统，动画 (`matchedGeometryEffect`, `transition`)。
- **@Engineer**: 负责业务逻辑，状态管理 (`@Observable` / `ObservableObject`)，Nuke 图片加载集成。

## 5. WORKFLOW
请按照 SPEC 文件的顺序逐步执行开发。不要一次性生成所有代码，确保每个模块独立可运行。
