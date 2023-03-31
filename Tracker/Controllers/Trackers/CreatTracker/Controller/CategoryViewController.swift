import UIKit

final class CategoryViewController: UIViewController {

    private var сategoryView: CategoryView!
    
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
    func addCategory(type: EditCategory) {
        let viewController = createEditCategoryViewController(type: type)
        present(viewController, animated: true)
    }
    
    func editCategory(type: EditCategory) {
        // TODO: меняем категорию
    }

}

// MARK: create CategoryViewController
extension CategoryViewController {
    private func createEditCategoryViewController(type: EditCategory) -> UINavigationController {
        let viewController = EditCategoryViewController()
        viewController.setEditType(type: type)
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}
