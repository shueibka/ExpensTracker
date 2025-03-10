//
//  ExpensesViewModel.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-07.
//

import SwiftUI 
import SwiftData

class ExpensesViewModel: ObservableObject {
    @Published var groupedExpenses: [GroupedExpenses] = []
    @Published var originalGroupedExpenses: [GroupedExpenses] = []
    @Published var addExpense: Bool = false
    @Published var searchText: String = ""
    
    /// Filters the grouped expenses based on the search text.
    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filtered = await self.originalGroupedExpenses.compactMap { group -> GroupedExpenses? in
                let expenses = group.expenses.filter { $0.title.lowercased().contains(query) }
                if expenses.isEmpty { return nil }
                return GroupedExpenses(date: group.date, expenses: expenses)
            }
            await MainActor.run {
                self.groupedExpenses = filtered
            }
        }
    }

    /// Resets filtering by restoring the original grouping.
    func resetFiltering() {
        groupedExpenses = originalGroupedExpenses
    }

    /// Groups expenses by date (day, month, year) and sorts them in descending order.
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
            }
            
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? Date()
                let date2 = calendar.date(from: $1.key) ?? Date()
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            await MainActor.run {
                self.groupedExpenses = sortedDict.compactMap { dict in
                    let date = Calendar.current.date(from: dict.key) ?? Date()
                    return GroupedExpenses(date: date, expenses: dict.value)
                }
                self.originalGroupedExpenses = self.groupedExpenses
            }
        }
    }

    /// Deletes an expense from a specific group and updates the grouping accordingly.
    func deleteExpense(_ expense: Expense, fromGroup groupID: UUID, context: ModelContext) {
        context.delete(expense)
        if let index = groupedExpenses.firstIndex(where: { $0.id == groupID }) {
            withAnimation {
                groupedExpenses[index].expenses.removeAll { $0.id == expense.id }
                if groupedExpenses[index].expenses.isEmpty {
                    groupedExpenses.remove(at: index)
                }
            }
        }
    }

    
}
