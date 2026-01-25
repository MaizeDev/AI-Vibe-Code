//
//  TabViews.swift
//  MySwiftUICodingProject
//
//  Created by wheat on 1/25/26.
//

import SwiftUI

struct TabViews: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeView()
            }

            Tab("Discover", systemImage: "safari", value: .discover) {
                DiscoverView()
            }

            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }

            Tab(value: .search, role: .search) {
                SearchView()
            }
        }
    }
}
