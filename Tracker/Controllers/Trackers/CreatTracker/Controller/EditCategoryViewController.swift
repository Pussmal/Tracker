import UIKit

final class EditCategoryViewController: UIViewController {

    private var editCategoryView: EditCategoryView!
    
    private struct CategoryViewControllerConstants {
        static let newCategoryTitle = "Новая категория"
        static let editCategoryTitle = "Редактирование категории"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editCategoryView = EditCategoryView(
            frame: view.bounds,
            delegate: self
        )
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        //title = CategoryViewControllerConstants.title
        addScreenView(view: editCategoryView)
    }
    
    func setEditType(type: EditCategory) {
        switch type {
        case .addCategory:
            title = CategoryViewControllerConstants.newCategoryTitle
        case .editCategory:
            title = CategoryViewControllerConstants.editCategoryTitle
        }
    }
    
    deinit {
        print("EditCategoryViewController deinit")
    }
}

extension EditCategoryViewController: EditCategoryViewDelegate {
    func editCategory() {
        print("изменили привычку")
    }
}
