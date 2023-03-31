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
