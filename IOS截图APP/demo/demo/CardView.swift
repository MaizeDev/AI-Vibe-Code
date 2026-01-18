import SwiftUI

struct CardView: View {

    let theme: CardTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            .white.opacity(0.15),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 18, y: 10)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(theme.name)
                        .font(.headline)
                        .foregroundStyle(theme.textColor)

                    Spacer()

                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(theme.textColor)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Spacer()

                Text("当前主题")
                    .font(.caption)
                    .foregroundStyle(theme.textColor.opacity(0.7))
            }
            .padding(20)
        }
        .frame(height: 180)
        .contentShape(RoundedRectangle(cornerRadius: 28))
    }
}
