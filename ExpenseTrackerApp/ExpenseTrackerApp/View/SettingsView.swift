//
//  SettingsView.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-08.
//

import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settings: [UserSettings]
    
    var body: some View {
        // Get the first settings record, or create one if missing.
        let userSettings = settings.first ?? {
            let newSettings = UserSettings()
            context.insert(newSettings)
            return newSettings
        }()
        
        return NavigationStack {
            Form {
                Section(header: Text("Saving Goal")) {
                    HStack {
                        Text("$")
                        TextField("Enter saving goal", value: Binding(
                            get: { userSettings.savingGoal },
                            set: { userSettings.savingGoal = $0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

