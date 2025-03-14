//
//  ExpenseTrackerAppApp.swift
//  ExpenseTrackerApp
//
//  Created by shueibka on 03/03/25.
//

import SwiftUI

@main
struct ExpenseTrackerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Expense.self, Category.self, UserSettings.self])
    }
}
