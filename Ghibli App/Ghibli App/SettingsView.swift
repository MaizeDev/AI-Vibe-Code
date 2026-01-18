//
//  SettingsView.swift
//  Ghibli App
//
//  Created by wheat on 1/18/26.
//
import SwiftUI


/// 设置页面，展示应用设置选项
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Label("Appearance", systemImage: "paintpalette")
                    Label("Notifications", systemImage: "bell")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0 (Build 2026)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}