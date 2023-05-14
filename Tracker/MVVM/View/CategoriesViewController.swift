import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func setCategory(categoryCoreData: TrackerCategoryCoreData?)
}

final class CategoriesViewController: UIViewController {
    
    // MARK: - public properties
    weak var delegate: CategoriesViewControllerDelegate?
    var category: String?
    
    // MARK: - private properties
    private var categoryCoreData: TrackerCategoryCoreData?
    
    private struct CategoryViewControllerConstants {
        static let title = "Категория"
        static let deleteActionSheetMessage = "Эта категория точно не нужна?"
        static let deleteActionTitle = "Удалить"
        static let cancelActionTitle = "Отмена"
        
        static let errorAlertTitle = "Ошибка"
        static let errorAlertMessage = "Нельзя удалить выбранную категорию"
        static let actionTitle = "OK"
    }
    
    // MARK: UI
    private var сategoriesView: CategoriesView!
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        сategoriesView = CategoriesView(
            frame: view.bounds,
            delegate: self,
            category: category
        )
        
        setupView()
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .clear
        title = CategoryViewControllerConstants.title
        addScreenView(view: сategoriesView)
    }
    
    deinit {
        print("CategoryViewController deinit")
    }
}

// MARK: CategoriesViewDelegate
extension CategoriesViewController: CategoriesViewDelegate {
    func showDeleteActionSheet(deleteCategory: TrackerCategoryCoreData) {
        var deleteActionSheet: UIAlertController {
            let message = CategoryViewControllerConstants.deleteActionSheetMessage
            let alertController = UIAlertController(
                title: nil, message: message,
                preferredStyle: .actionSheet
            )
            let deleteAction = UIAlertAction(
                title: CategoryViewControllerConstants.deleteActionTitle,
                style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                      let categoryStore = TrackerCategoryStore()
                    categoryStore.deleteCategory(delete: deleteCategory)
                    self.сategoriesView.reloadCollectionView()
                }
            let cancelAction = UIAlertAction(title: CategoryViewControllerConstants.cancelActionTitle, style: .cancel)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            return alertController
        }
        
        let viewController = deleteActionSheet
        present(viewController, animated: true)
    }
    
    func showErrorAlert() {
        var errorAlert: UIAlertController {
            let title = CategoryViewControllerConstants.errorAlertTitle
            let message = CategoryViewControllerConstants.errorAlertMessage
            let alertController = UIAlertController(
                title: title, message: message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: CategoryViewControllerConstants.actionTitle, style: .default)
            alertController.addAction(okAction)
            return alertController
        }
        
        let viewController = errorAlert
        present(viewController, animated: true)
    }
    
    func selectedCategory(categoryCoreData: TrackerCategoryCoreData?) {
        delegate?.setCategory(categoryCoreData: categoryCoreData)
    }
    
    func showEditCategoryViewController(type: EditCategory, editCategoryString: String?, at indexPath: IndexPath?) {
        let viewController = createEditCategoryViewController(type: type, editCategoryString: editCategoryString, at: indexPath)
        present(viewController, animated: true)
    }
}

// MARK: create CategoryViewController
extension CategoriesViewController {
    private func createEditCategoryViewController(type: EditCategory, editCategoryString: String?, at indexPath: IndexPath?) -> UINavigationController {
        let viewController = EditCategoryViewController()
        
        viewController.callBack = { [weak self] in
            guard let self = self else { return }
            
            self.сategoriesView.reloadCollectionView()
            self.categoryCoreData = $0
        }
        
        viewController.setEditType(type: type, editCategoryString: editCategoryString, at: indexPath)
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}
