import UIKit

final class EditCategoryViewController: UIViewController {

    private var editCategoryView: EditCategoryView!
    private var editCategoryText: String?
    private var indexPathEditCategory: IndexPath?
    
    private let categoryStory = TrackerCategoryStore()
    private var typeEditeCategory: EditCategory?
    
    var callBack:((TrackerCategoryCoreData?)->())?
    
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
        addScreenView(view: editCategoryView)
        editCategoryView.setTextFieldText(text: editCategoryText)
    }
    
    func setEditType(type: EditCategory, editCategoryString: String?, at indexPath: IndexPath?) {
        switch type {
        case .addCategory:
            title = CategoryViewControllerConstants.newCategoryTitle
        case .editCategory:
            title = CategoryViewControllerConstants.editCategoryTitle
            editCategoryText = editCategoryString
            indexPathEditCategory = indexPath
        }
        
        typeEditeCategory = type
    }
    
    deinit {
        print("EditCategoryViewController deinit")
    }
    
    private func creatNewCategory(category: String) -> TrackerCategoryCoreData  {
        let newCategory = TrackerCategory(title: category)
        return categoryStory.addTrackerCategoryCoreData(from: newCategory)
    }
    
    private func editCategory(newTitle: String, at indexPath: IndexPath) -> TrackerCategoryCoreData {
        categoryStory.changeCategory(at: indexPath, newCategoryTitle: newTitle)
    }
}

extension EditCategoryViewController: EditCategoryViewDelegate {
    func editCategory(category: String?) {
        guard let typeEditeCategory, let categoryString = category else { return }
        
        var categoryCoreData: TrackerCategoryCoreData?
        
        switch typeEditeCategory {
        case .addCategory:
            categoryCoreData = creatNewCategory(category: categoryString)
        case .editCategory:
            guard let indexPathEditCategory else { return }
            categoryCoreData = editCategory(newTitle: categoryString, at: indexPathEditCategory)
        }

        callBack?(categoryCoreData)
        dismiss(animated: true)
    }
}
