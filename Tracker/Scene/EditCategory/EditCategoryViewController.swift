import UIKit

final class EditCategoryViewController: UIViewController {

    //MARK: Callback
    var updateWithNewCategory: (()->())?
    
    private var editCategoryView: EditCategoryView!
    private var editCategoryText: String?
    private var indexPathEditCategory: IndexPath?
    private let categoryStory = TrackerCategoryStore()
    private var typeEditeCategory: EditCategory?
        
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
        configureKeyboard()
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
        
    private func configureKeyboard() {
        hideKeyboardWhenTappedAround()
    }
    
    private func creatNewCategory(category: String)  {
        let newCategory = TrackerCategory(title: category)
        categoryStory.addTrackerCategoryCoreData(from: newCategory)
    }
    
    private func editCategory(newTitle: String, at indexPath: IndexPath)  {
        var indexPath = indexPath
        //при первом включении мы создаем категорию закрепленные, нам ее показывать не нужно, поэтому для отображения прибавляю 1
        if indexPath.row >= 0 {
            indexPath.row += 1
        }
        
        categoryStory.changeCategory(at: indexPath, newCategoryTitle: newTitle)
    }
}

extension EditCategoryViewController: EditCategoryViewDelegate {
    func editCategory(category: String?) {
        guard let typeEditeCategory, let categoryString = category else { return }
        
        switch typeEditeCategory {
        case .addCategory:
            creatNewCategory(category: categoryString)
        case .editCategory:
            guard let indexPathEditCategory else { return }
            editCategory(newTitle: categoryString, at: indexPathEditCategory)
        }
        updateWithNewCategory?()
        dismiss(animated: true)
    }
}
