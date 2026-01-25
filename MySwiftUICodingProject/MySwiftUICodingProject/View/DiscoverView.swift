//
//  DiscoverView.swift
//  MySwiftUICodingProject
//
//  Created by wheat on 1/25/26.
//

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Image(systemName: "safari")
                    .font(.system(size: 100))

                Text("Discover")
                    .font(Font.largeTitle)
                
            }
            .foregroundStyle(Color.gray.opacity(0.5))
            .navigationTitle("Discover")
        }
    }
}

#Preview {
    DiscoverView()
}
