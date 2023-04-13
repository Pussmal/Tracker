import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func setCategory(category: String?)
}

final class CategoryViewController: UIViewController {
    
    private var сategoryView: CategoryView!
    weak var delegate: CategoryViewControllerDelegate?
    
    private struct CategoryViewControllerConstants {
        static let title = "Категория"
    }
    
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        сategoryView = CategoryView(
            frame: view.bounds,
            delegate: self,
            category: category
        )
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        сategoryView.reloadCollectionView()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        title = CategoryViewControllerConstants.title
        addScreenView(view: сategoryView)
    }
    
    private func reloadCollectionView() {
       
    }
    
    deinit {
        print("CategoryViewController deinit")
    }
    
}

extension CategoryViewController: CategoryViewDelegate {
    func selectCategory(category: String?) {
        delegate?.setCategory(category: category)
    }
    
    func showDeleteActionSheet(category: String?) {
        self.category = category
        
        var deleteActionSheet: UIAlertController {
            let message = "Эта категория точно не нужна?"
            let alertController = UIAlertController(
                title: nil, message: message,
                preferredStyle: .actionSheet
            )
            let deleteAction = UIAlertAction(
                title: "Удалить",
                style: .destructive) { [weak self] _ in
                    // TODO: удалить категорию обновить изображение
                    guard let self = self,
                          let category = self.category,
                          let index = CategoryStorage.shared.category.firstIndex(of: category)
                    else { return }
                    CategoryStorage.shared.category.remove(at: index)
                    self.сategoryView.reloadCollectionView()
                    print(CategoryStorage.shared.category.count)
                }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
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
extension CategoryViewController {
    private func createEditCategoryViewController(type: EditCategory, editCategoryString: String?) -> UINavigationController {
        let viewController = EditCategoryViewController()
        viewController.setEditType(type: type, editCategoryString: editCategoryString)
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}
