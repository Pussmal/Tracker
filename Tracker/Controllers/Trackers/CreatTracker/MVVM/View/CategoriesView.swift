import UIKit

enum EditCategory {
    case addCategory
    case editCategory
}

protocol CategoriesViewDelegate: AnyObject {
    func showEditCategoryViewController(type: EditCategory, editCategoryString: String?)
    func showDeleteActionSheet(category: String?)
    func selectedCategory(categoryCoreData: TrackerCategoryCoreData?)
}

final class CategoriesView: UIView {
    
    weak var delegate: CategoriesViewDelegate?
    
    private var viewModel: CategoriesViewModelProtocol?
    
    private var categoryCollectionViewCellHelperObserver: NSObjectProtocol?
    
    private struct CategoryViewConstant {
        static let collectionViewReuseIdentifier = "Cell"
        static let addButtontitle = "Добавить категорию"
        static let plugLabelText = """
            Привычки и события можно
            объединить по смыслу
        """
    }

    //MARK: UI
    private lazy var plugView: PlugView = {
        let plugView = PlugView(
            frame: .zero,
            titleLabel: CategoryViewConstant.plugLabelText,
            image: UIImage(named: "plug") ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryViewConstant.collectionViewReuseIdentifier
        )
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifire
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var addButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CategoryViewConstant.addButtontitle
        )
        button.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    init(
        frame: CGRect,
        delegate: CategoriesViewDelegate?,
        category: String? = nil
    ) {
        self.delegate = delegate
        
        super.init(frame: frame)
        
        viewModel = CategoriesViewModel(selectedCategory: category)
        
        viewModel?.hidePlugView = { [weak self] in
            guard let self = self else { return }
            self.plugView.isHidden = $0 ? true : false
        }
        
        viewModel?.needToUpdateCollectionView = { [weak self] in
            guard let self = self, $0 else { return }
            self.categoryCollectionView.reloadData()
        }
        
        if viewModel?.numberOfRows == 0 {
            plugView.isHidden = false
        }
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCollectionView() {
        viewModel?.updateCategories()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        addSubViews(
            categoryCollectionView,
            addButton,
            plugView
        )
    }
    
    private func activateConstraints() {
        let plugViewTopConstant = frame.height / 3.5
        
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            categoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            categoryCollectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            
            plugView.topAnchor.constraint(equalTo: topAnchor, constant: plugViewTopConstant),
            plugView.leadingAnchor.constraint(equalTo: leadingAnchor),
            plugView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func createContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard let self = self else { return UIMenu() }
            let category = self.viewModel?.getCategory(by: indexPath)?.title
    
            return UIMenu(children: [
                UIAction(title: "Редактировать") { _ in
                   // self.delegate?.editCategory(editCategoryString: string)
                },
                UIAction(title: "Удалить", attributes: .destructive, handler: { _ in
                   // self.delegate?.deleteCategory(delete: string)
                })
            ])
        })
    }
    
    @objc
    private func addButtonTapped() {
        addButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.showEditCategoryViewController(type: .addCategory, editCategoryString: nil)
        }
    }
}

//extension CategoriesView: CategoryCollectionViewHelperDelegate {
//    func selectCategory(category: String?) {
//        delegate?.selectedCategoryName(category: category)
//    }
//
//    func deleteCategory(delete: String?) {
//        delegate?.showDeleteActionSheet(category: delete)
//    }
//
//    func editCategory(editCategoryString: String?) {
//        delegate?.showEditCategoryViewController(type: .editCategory, editCategoryString: editCategoryString)
//    }
//}

extension CategoriesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfRows ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifire,
            for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        
        let categoryCellViewModel = viewModel?.categoryCellViewModel(with: indexPath)
        cell.initialize(viewModel: categoryCellViewModel)
        return cell
    }
}

extension CategoriesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryCoreData = viewModel?.didSelectCategory(by: indexPath)
        delegate?.selectedCategory(categoryCoreData: categoryCoreData)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        return createContextMenu(indexPath: indexPath)
    }
}

extension CategoriesView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - Constants.indentationFromEdges * 2
        return CGSize(width: width, height: Constants.hugHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

