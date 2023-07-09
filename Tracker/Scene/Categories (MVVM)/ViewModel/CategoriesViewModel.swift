import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol {
    var numberOfRows: Int { get }
    var hidePlugView: Binding<Bool>? { get set }
    var needToUpdateCollectionView: Binding<Bool>? { get set }
    func categoryCellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel?
    func getCategory(by indexPath: IndexPath) -> TrackerCategory?
    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData?
    func updateCategories()
    func needToHidePlugView()
}

final class CategoriesViewModel {
    var hidePlugView: Binding<Bool>?
    var needToUpdateCollectionView: Binding<Bool>?
   
    private let categoryStore: TrackerCategoryStoreProtocol
    private var selectedCategory: String?
    
    init(selectedCategory: String?, categoryStore: TrackerCategoryStoreProtocol) {
        self.selectedCategory = selectedCategory
        self.categoryStore = categoryStore
    }
}

// MARK: CategoriesViewModelProtocol
extension CategoriesViewModel: CategoriesViewModelProtocol {
    var numberOfRows: Int {
        guard let numberOfRows = categoryStore.fetchedResultsController.sections?[0].numberOfObjects else { return 0 }
        //при первом запуске мы создаем категорию "закрепленные", нам ее показывать не нужно, поэтому уменьшаю на 1
        return numberOfRows - 1
    }
    
    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData? {
        var indexPath = indexPath
        //при первом запуске мы создаем категорию "закрепленные", нам ее показывать не нужно, поэтому чтобы она не нажималась прибавляю 1
        if indexPath.row >= 0 {
            indexPath.row += 1
        }
        return categoryStore.getTrackerCategoryCoreData(by: indexPath)
    }
    
    func categoryCellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel? {
        var indexPath = indexPath
        //при первом запуске мы создаем категорию закрепленные, нам ее показывать не нужно, поэтому для отображения прибавляю 1
        if indexPath.row >= 0 {
            indexPath.row += 1
        }
        
        guard let category = categoryStore.getTrackerCategory(by: indexPath) else { return nil }
        let isSelected = selectedCategory == category.title
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
        let checkedValue = categoryStore.fetchedResultsController.sections?[0].numberOfObjects
        //при первом запуске мы создаем категорию закрепленные, нам ее показывать не нужно, поэтому plug показываем даже если одна категория
        let needToHidePlugView = checkedValue != 0 && checkedValue != 1
        needToHidePlugView ? hidePlugView?(true) : hidePlugView?(false)
    }
}

