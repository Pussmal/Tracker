
import UIKit

enum EditCategory {
    case addCategory
    case editCategory
}

protocol CategoryViewDelegate: AnyObject {
    func showEditCategoryViewController(type: EditCategory, editCategoryString: String?)
}

final class CategoryView: UIView {
    
    weak var delegate: CategoryViewDelegate?
    
    private struct CategoryViewConstant {
        static let collectionViewReuseIdentifier = "Cell"
        static let addButtontitle = "Добавить категорию"
    }
    
    private var сategoryCollectionViewCellHelper: CategoryCollectionViewCellHelper?
    
    private let colorCollectionView: UICollectionView = {
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
        delegate: CategoryViewDelegate?
    ) {
        self.delegate = delegate
       
        super.init(frame: frame)
        
        сategoryCollectionViewCellHelper = CategoryCollectionViewCellHelper(delegate: self)
        colorCollectionView.delegate = сategoryCollectionViewCellHelper
        colorCollectionView.dataSource = сategoryCollectionViewCellHelper
        
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        addSubViews(
            colorCollectionView,
            addButton
        )
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: topAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            colorCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            colorCollectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
        ])
    }
    
    @objc
    private func addButtonTapped() {
        addButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.showEditCategoryViewController(type: .addCategory, editCategoryString: nil)
        }
    }
}

extension CategoryView: CategoryCollectionViewCellHelperDelegate {
    func editCategory(editCategoryString: String?) {
        delegate?.showEditCategoryViewController(type: .editCategory, editCategoryString: editCategoryString)
    }
    
    func deleteCategory() {
        // удалить категорию
    }
}
