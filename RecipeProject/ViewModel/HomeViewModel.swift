import Foundation
import UIKit
import CoreData

class HomeViewModel {
    private let managedContext: NSManagedObjectContext
        private var categories: [Category] = []
        var selectedCategories: Set<Category> = []
        
        init(managedContext: NSManagedObjectContext) {
            self.managedContext = managedContext
        }
        
        func fetchCategories(completion: @escaping () -> Void) {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            do {
                categories = try managedContext.fetch(fetchRequest)
                completion()
            } catch {
                print("Error fetching categories: \(error)")
                completion()
            }
        }
    
    func configureCategoryCell(_ cell: CategoryCell, at indexPath: IndexPath) {
        let categoryName = categories[indexPath.item]
        cell.configure(with: categoryName.name!, isSelected: selectedCategories.contains(categoryName))
    }
    
    func toggleCategorySelection(at indexPath: IndexPath) {
        let categoryName = categories[indexPath.item]
        if selectedCategories.contains(categoryName) {
            selectedCategories.remove(categoryName)
        } else {
            selectedCategories.insert(categoryName)
        }
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func getCategoryName(at indexPath: IndexPath) -> String {
        return categories[indexPath.item].name ?? ""
    }
    
    func getCategoryCellSize(at indexPath: IndexPath) -> CGSize {
        let categoryName = categories[indexPath.item].name ?? ""
        let itemWidth = categoryName.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width + 20 // Add some extra padding
        return CGSize(width: itemWidth, height: 40)
    }
}
