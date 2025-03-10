//
//  AddExpenseViewModel.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-07.
//

import SwiftUI
import SwiftData


class AddExpenseViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var subTitle: String = ""
    @Published var date: Date = Date()
    @Published var amount: CGFloat = 0
    @Published var category: Category?
    
    
    var isAddButtonDisabled: Bool {
        title.isEmpty || subTitle.isEmpty || amount == .zero
    }

    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }

    /// Adds an Expense using the current values and then calls the dismiss closure.
    func addExpense(context: ModelContext, dismiss: () -> Void) {
        let expense = Expense(title: title,
                              subTitle: subTitle,
                              amount: Double(amount),
                              date: date,
                              category: category)
        context.insert(expense)
        dismiss()
    }

}
