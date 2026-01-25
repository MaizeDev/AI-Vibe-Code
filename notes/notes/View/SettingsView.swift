//
//  SettingsView.swift
//  notes
//
//  Created by wheat on 1/22/26.
//


import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("NotesX").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0").foregroundColor(.secondary)
                    }
                }
                
                Section("Data Management") {
                    Button("Delete All Notes", role: .destructive) {
                        let descriptor = FetchDescriptor<Note>()
                        if let notes = try? context.fetch(descriptor) {
                            for note in notes {
                                context.delete(note)
                            }
                            try? context.save()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}