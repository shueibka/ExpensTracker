//
//  CategoriesViewModel.swift
//  ExpenseTrackerApp
//
//  Created by Shueib on 2025-03-07.
//

//
//  CategoriesViewModel.swift
//  ExpenseTrackerApp
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import SwiftData

class CategoriesViewModel: ObservableObject {
    @Published var addCategory: Bool = false
    @Published var categoryName: String = ""
    @Published var deleteRequest: Bool = false
    @Published var requestedCategory: Category?
    
    /// Adds a new category to the data store.
    func addNewCategory(context: ModelContext) {
        let category = Category(categoryName: categoryName)
        context.insert(category)
        categoryName = ""
        addCategory = false
    }
    
    /// Deletes the selected category.
    func deleteCategory(context: ModelContext) {
        if let categoryToDelete = requestedCategory {
            context.delete(categoryToDelete)
            self.requestedCategory = nil
        }
    }
    
    
}

