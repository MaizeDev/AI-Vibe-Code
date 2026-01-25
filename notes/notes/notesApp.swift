//
//  notesApp.swift
//  notes
//
//  Created by wheat on 1/21/26.
//

import SwiftUI
import SwiftData

@main
struct notesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}
