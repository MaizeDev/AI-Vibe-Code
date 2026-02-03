git push origin main    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
>>>>>>> origin/main
    }
}

#Preview {
<<<<<<< HEAD
    CategoryIcon(category: .dining)
    CategoryIcon()
>>>>>>> origin/main
}
//
//  CategoryIcon.swift
//  ExpenseTrackerTutorial
//
//  Created by wheat on 2/3/26.
//

import SwiftUI

struct CategoryIcon: View {
    let category: AITransaction.Category
    
    var body: some View {
        let info = category.iconInfo
        
        Image(systemName: info.symbol)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(info.color.gradient)
            )
            .accessibilityHidden(true)
    }
}

#Preview {
    CategoryIcon(category: .dining)
}
=======
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
>>>>>>> origin/main
    }
}

#Preview {
    CategoryIcon(category: .dining)
}
