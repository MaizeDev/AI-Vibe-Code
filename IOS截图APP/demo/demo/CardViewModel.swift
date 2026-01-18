import SwiftUI
import Combine
final class CardViewModel: ObservableObject {

    /// 当前选中的主题（原有状态）
    @Published var selectedTheme: CardTheme = CardTheme.allThemes.first!

    /// 如果你后面有更多业务状态，继续放这里
}
