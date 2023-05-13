import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol {
    var numberOfRows: Int { get }
    
    var hidePlugView: Binding<Bool>? { get set }
    var needToUpdateCollectionView: Binding<Bool>? { get set }
    
    var addNewCategoryToCollectionView: Binding<IndexPath>? { get set }
    
    func categoryCellViewModel(with indexPath: IndexPath) -> CategoryCellViewModel?
    func getCategory(by indexPath: IndexPath) -> TrackerCategory?
    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData?
    
    func updateCategories()
}

final class CategoriesViewModel {
    
    var hidePlugView: Binding<Bool>?
    var needToUpdateCollectionView: Binding<Bool>?
    var addNewCategoryToCollectionView: Binding<IndexPath>?
    
    private var countOfCategories: Int?
            
    private var isHidePlugView = false {
        didSet {
            hidePlugView?(isHidePlugView)
        }
    }
        
    private let categoryStore = TrackerCategoryStore()
    
    private var selectedCategory: String?
   
    init(selectedCategory: String?) {
        isHidePlugView = categoryStore.fetchedResultsController.sections?[0].numberOfObjects == 0
        countOfCategories = categoryStore.fetchedResultsController.sections?[0].numberOfObjects
        self.selectedCategory = selectedCategory
    }

    
    deinit{
        print("CategoriesViewModel deinit")
    }
}

extension CategoriesViewModel: CategoriesViewModelProtocol {

    func didSelectCategory(by indexPath: IndexPath) -> TrackerCategoryCoreData? {
        categoryStore.getTrackerCategoryCoreData(by: indexPath)
    }
    
    var numberOfRows: Int {
        categoryStore.fetchedResultsController.sections?[0].numberOfObjects ?? 0
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
        needToUpdateCollectionView?(true)
    }
}

//extension CategoriesViewModel: CategoryCollectionViewHelperDelegate {
//    func editCategory(editCategoryString: String?) {}
//    
//    func deleteCategory(delete: String?) {}
//    
//    func updateCollectionView() {}
//    
//    func selectCategory(category: String?) {
//        guard let category else { return }
//        print(category)
//    }
//}
