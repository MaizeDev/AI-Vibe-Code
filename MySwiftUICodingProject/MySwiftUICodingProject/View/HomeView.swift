//
//  HomeView.swift
//  MySwiftUICodingProject
//
//  Created by wheat on 1/25/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Image(systemName: "house")
                    .font(.system(size: 100))
                
                Text("Home")
                    .font(Font.largeTitle)
            }
            .foregroundStyle(Color.gray.opacity(0.5))
            .navigationTitle("Home")
        }
        
    }
}

#Preview {
    HomeView()
}
