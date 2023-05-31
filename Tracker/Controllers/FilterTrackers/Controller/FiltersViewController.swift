import UIKit

final class FiltersViewController: UIViewController {
    
    private struct ViewControllerConstant {
        static let titleViewController = NSLocalizedString("filterTitle", comment: "Title view controller")
        static let collectionViewReuseIdentifier = "Cell"
    }
    
    //MARK: - private properties
    private let collectionViewProvider = FilterCollectionViewProvider()
    
    //MARK: UI
    private lazy var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: ViewControllerConstant.collectionViewReuseIdentifier
        )
        collectionView.register(
            FilterCollectionViewCell.self,
            forCellWithReuseIdentifier: FilterCollectionViewCell.cellReuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = collectionViewProvider
        collectionView.delegate = collectionViewProvider
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addViews()
        activateConstraints()
    }
    
    private func setupView() {
        title = ViewControllerConstant.titleViewController
        view.backgroundColor = .ypWhite
    }
    
    private func addViews() {
        view.addSubview(filterCollectionView)
    }
    
    private func activateConstraints() {
        [
            filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges),
            filterCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { $0.isActive = true }
    }
}
