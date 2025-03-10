//
//  UserSettings.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-08.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class UserSettings {
    var savingGoal: Double = 0.0
    
    init(savingGoal: Double = 0.0) {
        self.savingGoal = savingGoal
    }
}
