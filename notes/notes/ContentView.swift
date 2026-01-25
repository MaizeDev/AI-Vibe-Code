//
//  ContentView.swift
//  notes
//
//  Created by wheat on 1/21/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var showCompose = false
    @State private var selectedTab: Tabs = .home

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView()
                }

                Tab("Favorites", systemImage: "star", value: .favorites) {
                    FavoritesView()
                }

                Tab("Settings", systemImage: "gear", value: .settings) {
                    SettingsView()
                }

                Tab(value: .search, role: .search) {
                    SearchView()
                }
            }

            // Floating + button
            Button(action: { showCompose = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 20) // 保持右边距
            .padding(.bottom, 80) // ⭐️ 关键修改：增加底部距离，避开 TabBar (通常 50-80 比较合适)
            // .offset(y: -20)      // ❌ 删除原来的 offset，用 padding 控制更稳定
        }
        .fullScreenCover(isPresented: $showCompose) {
            ComposeView()
        }
    }
}

enum Tabs: Hashable {
    case home, favorites, search, settings
}

#Preview {
    ContentView()
}
