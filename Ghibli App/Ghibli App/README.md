# Ghibli App - 吉卜力电影浏览器

## 项目概述

Ghibli App 是一款现代化的 iOS 应用，专门用于浏览和欣赏吉卜力工作室的经典动画电影。该应用结合了云端数据获取、本地数据缓存、收藏功能以及流畅的用户界面设计，为用户提供了一个优雅的吉卜力世界探索体验。

## 技术架构

本项目采用了经典的 MVVM（Model-View-ViewModel）架构模式：

- **Model**: 定义数据结构（[Movie.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/Movie.swift)）
- **ViewModel**: 管理应用状态和业务逻辑（[AppStore.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/AppStore.swift)）
- **View**: 展示用户界面（如[MoviesFeedView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/MoviesFeedView.swift)等）

## 主要功能

### 1. 云端数据获取
- 通过 Ghibli API 获取吉卜力电影的真实数据
- 支持在线和离线模式切换

### 2. 电影浏览
- 以卡片形式展示电影信息（标题、海报、简介、评分等）
- 流畅的滚动体验和视觉效果

### 3. 电影详情
- 详细的电影信息展示
- 包含电影海报、描述、导演、评分等

### 4. 收藏功能
- 用户可以收藏喜爱的电影
- 使用 SwiftData 进行本地数据持久化

### 5. 搜索功能
- 支持按电影标题搜索
- 实时搜索结果反馈

### 6. 自定义导航
- 独特的悬浮式导航栏设计
- 分岛式导航概念，增强用户体验

## 文件结构及功能详解

### 核心文件

#### [Ghibli_AppApp.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/Ghibli_AppApp.swift)
- 应用程序入口点
- 初始化 SwiftData 容器并设置主窗口
- 配置应用的生命周期和场景

#### [ContentView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/ContentView.swift)
- 应用主内容视图
- 管理底部导航栏和内容区域
- 通过状态管理切换不同的页面视图

#### [AppStore.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/AppStore.swift)
- 应用状态管理器
- 负责获取和管理电影数据
- 处理加载状态和错误情况

### 数据模型文件

#### [Movie.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/Movie.swift)
- 电影数据模型定义
- 包含电影的所有属性（ID、标题、描述、评分等）
- 定义收藏模型 FavoriteMovie 用于 SwiftData 持久化

#### [GhibliClient.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/GhibliClient.swift)
- 网络请求客户端
- 支持在线 API 请求和本地数据模拟
- 提供统一的电影数据获取接口

#### [LocalData.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/LocalData.swift)
- 本地模拟数据存储
- 包含几部吉卜力经典电影的数据样本
- 用于开发和测试阶段

### UI 组件文件

#### [FloatingTabBar.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/FloatingTabBar.swift)
- 自定义悬浮导航栏
- 采用分岛式设计（左侧主要功能，右侧独立搜索）
- 具备流畅的动画效果和触觉反馈

#### [AppTab.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/AppTab.swift)
- 导航标签枚举
- 定义所有导航项及其图标状态

#### [MovieCard.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/MovieCard.swift)
- 电影卡片组件
- 展示电影的缩略信息
- 包含收藏按钮和视觉效果

#### [MovieDetailView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/MovieDetailView.swift)
- 电影详情页面
- 展示完整的电影信息
- 使用渐变效果和网格背景增强视觉体验

#### [InfoBadge.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/InfoBadge.swift)
- 信息徽章组件
- 用于展示统计数据（时长、评分、年份等）

### 页面视图文件

#### [MoviesFeedView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/MoviesFeedView.swift)
- 电影列表页面
- 显示所有电影的滚动列表
- 集成收藏功能

#### [FavoritesView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/FavoritesView.swift)
- 收藏页面
- 显示用户收藏的电影
- 支持删除功能

#### [SearchView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/SearchView.swift)
- 搜索页面
- 支持按标题搜索电影
- 提供搜索建议和结果展示

#### [SettingsView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/SettingsView.swift)
- 设置页面
- 应用设置选项（预留功能）

## 设计特色

### UI 设计
- 采用 iOS 16+ 的新特性，如磨砂玻璃效果、视觉层次
- 使用 SF Symbols 图标提供一致的视觉体验
- 流畅的动画和转场效果

### 交互设计
- 悬浮式导航栏设计，提升操作便利性
- 触觉反馈增强交互感受
- 智能滚动效果和视觉差动画

### 数据管理
- 结合云端 API 和本地数据，确保应用可用性
- 使用 SwiftData 进行高效的数据持久化
- 智能缓存策略减少网络请求

## 技术栈

- **SwiftUI**: 声明式 UI 框架
- **SwiftData**: 苹果最新的数据持久化框架
- **Async/Await**: 现代异步编程范式
- **JSONDecoder**: 数据解析
- **URLSession**: 网络请求
- **SF Symbols**: 系统图标库

## 开发指南

### 本地运行

1. 打开项目
2. 确保 Xcode 版本支持 iOS 17+
3. 选择合适的模拟器或设备
4. 构建并运行项目

### 数据源切换

在 [GhibliClient.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/GhibliClient.swift) 中，可以通过修改 `useLocalData` 常量来切换数据源：
- `true`: 使用本地模拟数据（适合开发调试）
- `false`: 使用在线 API 数据（适合生产环境）

### 扩展功能

1. 可以通过扩展 [Movie](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/Movie.swift) 模型添加更多电影属性
2. 可以在 [SettingsView.swift](file:///Users/wheat/Desktop/Ghibli%20App/Ghibli%20App/SettingsView.swift) 中添加更多设置选项
3. 可以为电影卡片添加更多交互功能

## 依赖项

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

此项目仅供学习和参考使用。

## 致谢

- 感谢吉卜力工作室创作的优秀作品
- 使用了 Ghibli API 提供的数据服务
- 使用了 TMDB 的电影图像资源