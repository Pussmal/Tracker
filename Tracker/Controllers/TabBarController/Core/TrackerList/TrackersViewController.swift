import UIKit

final class TrackersViewController: UIViewController {
    
    private struct TrackersListControllerConstants {
        static let plugLabelText = "Что будем отслеживать?"
    }
    
    private var categories: [TrackerCategory] =
    [
        //        TrackerCategory(
        //            title: "Домашний уют",
        //            trackers: [
        //                Tracker(id: UUID().uuidString, name: "Поливать растения", color: .ypColorSelection5, emoji: "🙂", schedule: nil),
        //                Tracker(id: UUID().uuidString, name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection3, emoji: "🌺", schedule: nil)
        //            ]),
        //        TrackerCategory(
        //            title: "Важное",
        //            trackers: [
        //                Tracker(id: UUID().uuidString, name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection5, emoji: "🙂", schedule: nil),
        //                Tracker(id: UUID().uuidString, name: "Поливать растения", color: .ypColorSelection3, emoji: "🌺", schedule: nil)
        //            ])
    ]
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var visibleCategories: [TrackerCategory] = []  // тут отфильтрованные трекеры
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var currentDate: Date {
        return datePicker.date
    }
    
    private var today: Date {
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let today = Calendar.current.date(from: dateComponents)
        return today ?? Date()
    }
    
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
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    private func getDayCount(id: String) -> Int {
        var completedDaysCount = 0
        completedTrackers.forEach {
            if $0.trackerID == id { completedDaysCount += 1 }
        }
        return completedDaysCount
    }
    
    private func getTracker(indexPath: IndexPath) -> Tracker {
        isFiltering ? visibleCategories[indexPath.section].trackers[indexPath.row] : categories[indexPath.section].trackers[indexPath.row]
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
        isFiltering ? visibleCategories.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? visibleCategories[section].trackers.count : categories[section].trackers.count
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
        
        let tracker = getTracker(indexPath: indexPath)
        let completedDayCount = getDayCount(id: tracker.id)
        cell.config(tracker: tracker, completedDaysCount: completedDayCount)
        cell.delegate = self
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
    func dismissViewController(_ viewController: UIViewController) {
        dismiss(animated: true)
    }
    
    func creactTrackerCategory(_ trackerCategory: TrackerCategory?) {
        guard let trackerCategory else { return }
        
        guard !categories.contains(trackerCategory) else {
            for (index, category) in categories.enumerated() {
                if category.title == trackerCategory.title {
                    let trackers = category.trackers + trackerCategory.trackers
                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
                    categories[index] = newTrackerCategory
                    self.collectionView.reloadData()
                }
            }
            dismiss(animated: true)
            return
        }
        
        categories.append(trackerCategory)
        collectionView.reloadData()
        if !categories.isEmpty { plugView.isHidden = true }
        dismiss(animated: true)
    }
}

// MARK: TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker(id: String?, completed: Bool) {
        guard let id = id else { return }
        let completedTracker = TrackerRecord(trackerID: id, checkDate: today)
        if completed {
            completedTrackers.insert(completedTracker)
        } else {
            completedTrackers.remove(completedTracker)
        }
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


