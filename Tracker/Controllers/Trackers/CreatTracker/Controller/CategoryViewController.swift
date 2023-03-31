import UIKit

final class CategoryViewController: UIViewController {
    
    private var сategoryView: CategoryView!
    
    private var deleteActionSheet: UIAlertController {
        let message = "Эта категория точно не нужна?"
        let alertController = UIAlertController(
            title: nil, message: message,
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive) { _ in
                // TODO: удалить категорию обновить изображение
            }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    private struct CategoryViewControllerConstants {
        static let title = "Категория"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        сategoryView = CategoryView(
            frame: view.bounds,
            delegate: self
        )
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        title = CategoryViewControllerConstants.title
        addScreenView(view: сategoryView)
    }
    
    deinit {
        print("CategoryViewController deinit")
    }
    
}

extension CategoryViewController: CategoryViewDelegate {
    func showDeleteActionSheet() {
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
