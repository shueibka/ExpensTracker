//
//  CategoriesView.swift
//  ExpenseTrackerApp
//
//  Created by shueibka on 04/03/25.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query(animation: .snappy) private var allCategories: [Category]
    // Explicitly provide the sort descriptor type for UserSettings.
    @Query(sort: [] as [SortDescriptor<UserSettings>]) private var userSettings: [UserSettings]
    @Environment(\.modelContext) private var context
    /// Existing view model for add/delete logic.
    @StateObject private var viewModel = CategoriesViewModel()
    /// View model for computing summary (total spent & saving goal).
    @StateObject private var summaryViewModel = CategoriesSummaryViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // Category list header is now the custom navigation title.
                ForEach(allCategories.sorted(by: {
                    ($0.expenses?.count ?? 0) > ($1.expenses?.count ?? 0)
                })) { category in
                    DisclosureGroup {
                        if let expenses = category.expenses, !expenses.isEmpty {
                            ForEach(expenses) { expense in
                                ExpenseCardView(expense: expense, displayTag: false)
                            }
                        } else {
                            ContentUnavailableView {
                                Label("No Expenses", systemImage: "tray.fill")
                            }
                        }
                    } label: {
                        Text(category.categoryName)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            viewModel.deleteRequest.toggle()
                            viewModel.requestedCategory = category
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .overlay {
                if allCategories.isEmpty {
                    ContentUnavailableView {
                        Label("No Categories", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                // Custom principal toolbar item for title and subtitle.
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Categories").font(.headline)
                        if let settings = userSettings.first {
                            Text("Saving Goal: \(settings.savingGoal, format: .currency(code: Locale.current.currencyCode ?? "USD"))")
                                .font(.caption)
                        }
                    }
                }
                // Button to add a new category.
                ToolbarItem(placement: .topBarTrailing) {
                    Button { viewModel.addCategory.toggle() } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                // Button to navigate to Settings.
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }
                }
            }
            .sheet(isPresented: $viewModel.addCategory) {
                resetCategoryName()
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("General", text: $viewModel.categoryName)
                        }
                    }
                    .navigationTitle("Category Name")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                viewModel.addCategory = false
                            }
                            .tint(.red)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                viewModel.addNewCategory(context: context)
                            }
                            .disabled(viewModel.categoryName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(180)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
        }
        .alert("If you delete a category, all the associated expenses will be deleted too.", isPresented: $viewModel.deleteRequest) {
            Button(role: .destructive) {
                viewModel.deleteCategory(context: context)
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                viewModel.requestedCategory = nil
            } label: {
                Text("Cancel")
            }
        }
        .onAppear {
            let currentSavingGoal = userSettings.first?.savingGoal ?? 0.0
            summaryViewModel.updateSummary(with: allCategories, savingGoal: currentSavingGoal)
        }
        .onChange(of: allCategories) { newValue in
            let currentSavingGoal = userSettings.first?.savingGoal ?? 0.0
            summaryViewModel.updateSummary(with: newValue, savingGoal: currentSavingGoal)
        }
        .onChange(of: userSettings.first?.savingGoal) { newValue in
            let currentSavingGoal = newValue ?? 0.0
            summaryViewModel.updateSummary(with: allCategories, savingGoal: currentSavingGoal)
        }
    }
    
    /// Resets the category name when the add sheet is dismissed.
    private func resetCategoryName() {
        viewModel.categoryName = ""
    }
}
