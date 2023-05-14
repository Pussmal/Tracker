import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol {
    var numberOfRows: Int { get }
    var hidePlugView: Binding<Bool>? { get set }
    var needToUpdateCollectionView: Binding<Bool>? { get set }
    func categoryCellViewModel(with indexPath: IndexPath) -> CategoryCellViewModel?
    func getCategory(by indexPath: IndexPath) -> TrackerCategory?
    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData?
    func updateCategories()
    func needToHidePlugView()
}

final class CategoriesViewModel {
    var hidePlugView: Binding<Bool>?
    var needToUpdateCollectionView: Binding<Bool>?
   
    private let categoryStore = TrackerCategoryStore()
    private var selectedCategory: String?
    
    init(selectedCategory: String?) {
        self.selectedCategory = selectedCategory
    }
    
    deinit{
        print("CategoriesViewModel deinit")
    }
}

// MARK: CategoriesViewModelProtocol
extension CategoriesViewModel: CategoriesViewModelProtocol {
    var numberOfRows: Int {
        categoryStore.fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData? {
        categoryStore.getTrackerCategoryCoreData(by: indexPath)
    }
    
    func categoryCellViewModel(with indexPath: IndexPath) -> CategoryCellViewModel? {
        guard let category = categoryStore.getTrackerCategory(by: indexPath) else { return nil }
        let isSelected = selectedCategory == category.title ? true : false
        return CategoryCellViewModel(category: category, isSelect: isSelected)
    }
    
    func getCategory(by indexPath: IndexPath) -> TrackerCategory? {
        categoryStore.getTrackerCategory(by: indexPath)
    }
    
    func updateCategories() {
        try? categoryStore.fetchedResultsController.performFetch()
        needToHidePlugView()
        needToUpdateCollectionView?(true)
    }
    
    func needToHidePlugView() {
        let needToHidePlugView = categoryStore.fetchedResultsController.sections?[0].numberOfObjects != 0
        needToHidePlugView ? hidePlugView?(true) : hidePlugView?(false)
    }
}

