import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = CardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(spacing: 24) {

                        header

                        CardView(theme: viewModel.selectedTheme)

                        themeSelector
                    }
                    .padding()
                }
            }
            .navigationTitle("Theme Center")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Subviews
private extension ContentView {

    var background: some View {
        LinearGradient(
            colors: [.black, .gray.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("视觉主题")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("选择你喜欢的卡片风格")
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var themeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CardTheme.allThemes) { theme in
                    Button {
                        viewModel.selectedTheme = theme
                    } label: {
                        Text(theme.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(
                                viewModel.selectedTheme.id == theme.id
                                ? .black
                                : .white
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectedTheme.id == theme.id
                                ? .white
                                : .white.opacity(0.15)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
