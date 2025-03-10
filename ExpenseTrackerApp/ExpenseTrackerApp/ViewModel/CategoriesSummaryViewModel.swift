//
//  CategoriesSummaryViewModel.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-08.
//

import Foundation
import SwiftUI

@MainActor
class CategoriesSummaryViewModel: ObservableObject {
    @Published var totalSpent: Double = 0.0
    @Published var savingGoal: Double = 0.0
    
    /// The difference (saving goal minus total spent).
    var difference: Double {
        savingGoal - totalSpent
    }
    
    /// Updates the summary from the current categories and saving goal.
    func updateSummary(with categories: [Category], savingGoal: Double) {
        totalSpent = categories.reduce(0.0) { sum, category in
            sum + (category.expenses?.reduce(0.0, { $0 + $1.amount }) ?? 0.0)
        }
        self.savingGoal = savingGoal
    }
}
