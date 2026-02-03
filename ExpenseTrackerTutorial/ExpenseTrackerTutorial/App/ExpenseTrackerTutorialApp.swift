//
//  ExpenseTrackerTutorialApp.swift
//  ExpenseTrackerTutorial
//
//  Created by wheat on 2/2/26.
//

import SwiftData
import SwiftUI

@main
struct ExpenseTrackerTutorialApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([AITransaction.self])
        let config = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
//
    }
}
