//
//  SettingsView.swift
//  MySwiftUICodingProject
//
//  Created by wheat on 1/25/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Image(systemName: "gear")
                    .font(.system(size: 100))

                Text("Settings")
                    .font(Font.largeTitle)
            }
            .foregroundStyle(Color.gray.opacity(0.5))
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
