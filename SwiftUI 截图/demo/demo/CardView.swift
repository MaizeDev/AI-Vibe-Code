import SwiftUI

struct CardView: View {
    let text: String
    let theme: CardTheme
    let author: String
    
    var body: some View {
        ZStack {
            // 背景层
            Rectangle()
                .fill(theme.background)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 装饰性引号
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.textColor.opacity(0.6))
                    Spacer()
                }
                
                // 主要文字内容
                Text(text.isEmpty ? "在此输入文字..." : text)
                    .font(.custom(theme.fontName, size: 22))
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                
                // 底部署名
                HStack {
                    Spacer()
                    Text("— \(author.isEmpty ? "未名" : author)")
                        .font(.custom(theme.fontName, size: 14))
                        .foregroundStyle(theme.textColor.opacity(0.8))
                        .italic()
                    Image(systemName: "quote.closing")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.textColor.opacity(0.6))
                }
                .padding(.top, 10)
            }
            .padding(40)
        }
        .frame(width: 375, height: 375) // 固定宽高比，方便导出正方形图片
        .clipShape(RoundedRectangle(cornerRadius: 0)) // 导出时通常不需要圆角，或者在外部加
    }
}

#Preview {
    CardView(text: "safasdfsd", theme: CardTheme(name: "极简白", background: AnyShapeStyle(Color.white), textColor: .black, fontName: "PingFangSC-Regular"), author: "sadf")
}
