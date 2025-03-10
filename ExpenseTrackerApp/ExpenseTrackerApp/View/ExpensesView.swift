//
//  ExpensesView.swift
//  ExpenseTrackerApp
//
//  Created by shueibka on 03/03/25.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @Binding var currentTab: String
    @Query private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    @State private var viewModel = ExpensesViewModel()
    
    var body: some View {
            NavigationStack {
                List {
                    ForEach(viewModel.groupedExpenses) { group in
                        Section(group.groupTitle) {
                            ForEach(group.expenses) { expense in
                                ExpenseCardView(expense: expense)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            viewModel.deleteExpense(expense, fromGroup: group.id, context: context)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Expenses")
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
                .overlay {
                    if allExpenses.isEmpty || viewModel.groupedExpenses.isEmpty {
                        ContentUnavailableView {
                            Label("No Expenses", systemImage: "tray.fill")
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { viewModel.addExpense.toggle() } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
            .onAppear {
                // Initialize groupedExpenses with the current saved expenses.
                viewModel.createGroupedExpenses(allExpenses)
            }
            .onChange(of: viewModel.searchText) { newValue in
                if !newValue.isEmpty {
                    viewModel.filterExpenses(newValue)
                } else {
                    viewModel.resetFiltering()
                }
            }
            .onChange(of: allExpenses) { newExpenses in
                if newExpenses.count > viewModel.originalGroupedExpenses.flatMap({ $0.expenses }).count ||
                    viewModel.groupedExpenses.isEmpty || currentTab == "Categories" {
                    viewModel.createGroupedExpenses(newExpenses)
                }
            }
            .sheet(isPresented: $viewModel.addExpense) {
                AddExpenseView()
                    .interactiveDismissDisabled()
            }
        }
    }
