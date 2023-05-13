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
    func selectedCategory(categoryCoreData: TrackerCategoryCoreData?) {
        delegate?.setCategory(categoryCoreData: categoryCoreData)
    }
        
    func showDeleteActionSheet(category: String?) {
        self.category = category
        
        var deleteActionSheet: UIAlertController {
            let message = CategoryViewControllerConstants.deleteActionSheetMessage
            let alertController = UIAlertController(
                title: nil, message: message,
                preferredStyle: .actionSheet
            )
            let deleteAction = UIAlertAction(
                title: CategoryViewControllerConstants.deleteActionTitle,
                style: .destructive) { [weak self] _ in
                    guard let self = self
                         
                    else { return }
                   
                }
            let cancelAction = UIAlertAction(title: CategoryViewControllerConstants.cancelActionTitle, style: .cancel)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            return alertController
        }
        
        let viewController = deleteActionSheet
        present(viewController, animated: true)
    }
    
    func showEditCategoryViewController(type: EditCategory, editCategoryString: String?) {
        let viewController = createEditCategoryViewController(type: type, editCategoryString: editCategoryString)
        present(viewController, animated: true)
    }
}

// MARK: create CategoryViewController
extension CategoriesViewController {
    private func createEditCategoryViewController(type: EditCategory, editCategoryString: String?) -> UINavigationController {
        let viewController = EditCategoryViewController()
        
        viewController.callBack = { [weak self] in
            guard let self = self else { return }
                        
            self.сategoriesView.reloadCollectionView()
            self.categoryCoreData = $0
        }
        
        viewController.setEditType(type: type, editCategoryString: editCategoryString)
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}
