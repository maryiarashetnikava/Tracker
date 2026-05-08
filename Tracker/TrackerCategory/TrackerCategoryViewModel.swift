import Foundation

final class TrackerCategoryViewModel {
    
    // MARK: - Dependencies
    
    private let store: TrackerCategoryStore
    var selectedCategory: TrackerCategoryCoreData?
    
    // MARK: - Bindings
    
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    var onAddCategoryRequested: (() -> Void)?
    var onEditCategory: ((TrackerCategoryCoreData) -> Void)?
    var onDeleteCategory: ((TrackerCategoryCoreData) -> Void)?
    
    // MARK: - Init
    
    init(store: TrackerCategoryStore, selectedCategory: TrackerCategoryCoreData?) {
        self.store = store
        self.selectedCategory = selectedCategory
        
        store.delegate = self
    }
    
    // MARK: - Public
    
    var numberOfCategories: Int {
        store.numberOfCategories
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData {
        store.category(at: indexPath)
    }
    
    func addCategory(title: String) {
        store.addCategory(title: title)
    }
    
    func didSelectCategory(at indexPath: IndexPath) {
        let category = store.category(at: indexPath)
        selectedCategory = category
        
        onCategorySelected?(category)
        onCategoriesChanged?()
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        let category = store.category(at: indexPath)
        return category == selectedCategory
    }
    
    func didTapAddCategory() {
        onAddCategoryRequested?()
    }
    
    func didTapEdit(at indexPath: IndexPath) {
        let category = store.category(at: indexPath)
        onEditCategory?(category)
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        let category = store.category(at: indexPath)
        onDeleteCategory?(category)
    }
    
    func updateCategory(_ category: TrackerCategoryCoreData, title: String) {
        store.update(category: category, title: title)

    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
        store.delete(category: category)
    }
}

// MARK: - Store Delegate

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    
    func didUpdateCategories() {
        onCategoriesChanged?()
    }
}
