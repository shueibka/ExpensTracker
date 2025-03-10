//
//  AddExpenseView.swift
//  ExpenseTrackerApp
//
//  Created by shueibka on 04/03/25..
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    /// View uses the view model for state and logic.
    @State private var viewModel = AddExpenseViewModel()
    /// Category data remains in the view.
    @Query(animation: .snappy) private var allCategories: [Category]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Title") {
                    TextField("Magic Keyboard", text: $viewModel.title)
                }
                
                Section("Description") {
                    TextField("Bought a keyboard at the Apple Store", text: $viewModel.subTitle)
                }
                
                Section("Amount Spent") {
                    HStack(spacing: 4) {
                        Text("$")
                            .fontWeight(.semibold)
                        
                        TextField("0.0",
                                  value: $viewModel.amount,
                                  formatter: viewModel.formatter)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Date") {
                    DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
                if !allCategories.isEmpty {
                    HStack {
                        Text("Category")
                        Spacer()
                        Menu {
                            ForEach(allCategories) { category in
                                Button(category.categoryName) {
                                    viewModel.category = category
                                }
                            }
                            Button("None") {
                                viewModel.category = nil
                            }
                        } label: {
                            if let categoryName = viewModel.category?.categoryName {
                                Text(categoryName)
                            } else {
                                Text("None")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        viewModel.addExpense(context: context) { dismiss() }
                    }
                    .disabled(viewModel.isAddButtonDisabled)
                }
            }
        }
    }
}

#Preview {
    AddExpenseView()
}
