import UIKit

final class TrackersViewController: UIViewController {
    
    private struct TrackersListControllerConstants {
        static let plugLabelText = "Что будем отслеживать?"
    }
    
    private var categories: [TrackerCategory] =
    [
        TrackerCategory(
            title: "Домашний уют",
            trackers: [
                Tracker(id: UUID().uuidString, name: "Поливать растения", color: .ypColorSelection5, emoji: "🙂", schedule: nil),
                Tracker(id: UUID().uuidString, name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection3, emoji: "🌺", schedule: nil)
            ]),
        TrackerCategory(
            title: "Приколюхи",
            trackers: [
                Tracker(id: UUID().uuidString, name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection5, emoji: "🙂", schedule: nil),
                Tracker(id: UUID().uuidString, name: "Поливать растения", color: .ypColorSelection3, emoji: "🌺", schedule: nil)
            ])
    ] {
        didSet {
            if !categories.isEmpty {
                plugView.isHidden = false
                plugView.config(title: TrackersListControllerConstants.plugLabelText, image: UIImage(named: "plug"))
            } else {
                plugView.isHidden = true
            }
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var visibleCategories: [TrackerCategory] = []  // тут отфильтрованные трекеры
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: UI
    private lazy var addTrackerButton: UIBarButtonItem = {
        let imageButton = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(
            image: imageButton,
            style: .done,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifire)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var plugView: PlugView = {
        let plugView = PlugView(
            frame: .zero,
            titleLabel: TrackersListControllerConstants.plugLabelText,
            image: UIImage(named: "plug") ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addSubviews()
        activateConstraints()
        setupSearchController()
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
        title = "Трекеры"
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSubviews() {
        
        view.addSubViews(
            collectionView,
            plugView
        )
        
        if categories.isEmpty {
            plugView.isHidden = false
        }
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: setup searchController
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.delegate = self
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc
    private func addTrackerButtonTapped() {
        showTypeTrackerViewController()
    }
    
    @objc
    private func valueChanged(_ sender: UIDatePicker) {
       
    }
}

// MARK: UICollectionView
extension TrackersViewController: UICollectionViewDelegate {}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 44) / 2
        let size = CGSize(width: width, height: 132)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 20
        return CGSize(width: width, height: height)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltering {
            return visibleCategories.count
        }
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return visibleCategories[section].trackers.count
        }
        
        return categories[section].trackers.count
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker: Tracker
        
        if isFiltering {
            tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        } else {
            tracker = categories[indexPath.section].trackers[indexPath.row]
        }
        
        cell.delegate = self
        cell.config(tracker: tracker)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.reuseIdentifire, for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        let title: String
        
        if isFiltering {
            title = visibleCategories[indexPath.section].title
        } else {
            title = categories[indexPath.section].title
        }
        
        view.config(title: title)
        return view
    }
}

// MARK: TypeTrackerViewController
extension TrackersViewController {
    private func showTypeTrackerViewController() {
        let typeTrackerViewController = TypeTrackerViewController()
        typeTrackerViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: typeTrackerViewController)
        present(navigationViewController, animated: true)
    }
}

extension TrackersViewController: TypeTrackerViewControllerDelegate {
    func dismissViewController() {
        dismiss(animated: true)
    }
}

// MARK: TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker() {
        print("Чекнул привычку")
    }
}


extension TrackersViewController {
    func createReusableView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath,
        title: String
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderReusableView.reuseIdentifire,
                for: indexPath) as? HeaderReusableView
        else { return UICollectionReusableView() }
        view.config(title: title)
        return view
    }
}

// MARK: UISearchResultsUpdating, UISearchControllerDelegate
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            visibleCategories = []
        } else {
            filterContentForSearchText(searchController.searchBar.text)
        }
    }
    
    private func filterContentForSearchText (_ searchText: String?) {
        guard let searchText else { return }
    
        // TODO: сделать поиск
        
        if visibleCategories.isEmpty && searchText != "" {
            plugView.isHidden = false
            plugView.config(title: "Ничего не найдено", image: UIImage(named: "notFound"))
        } else {
            plugView.isHidden = true
        }
        
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        visibleCategories = []
        plugView.isHidden = true
        collectionView.reloadData()
    }
}


