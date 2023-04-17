import UIKit

final class TrackersViewController: UIViewController {
    
    private struct TrackersListControllerConstants {
        static let plugLabelText = "Что будем отслеживать?"
    }

    private let searchController = UISearchController(searchResultsController: nil)
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = [] // тут отфильтрованные трекеры
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var currentDate: Date {
        let currentDate = Date().getDate(date: datePicker.date)
        return currentDate
    }
    
    private var today: Date {
        let today = Date().getDate(date: Date())
        return today
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
        picker.calendar = Calendar(identifier: .iso8601)
        picker.addTarget(self, action: #selector(changedDate), for: .valueChanged)
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
        showVisibleTrackers()
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
        title = "Трекеры"
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSubviews() {
        view.addSubViews(collectionView, plugView)
        if categories.isEmpty { plugView.isHidden = false }
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
    private func changedDate() {
        showVisibleTrackers()
        print(completedTrackers)
    }
    
    private func getDayCount(for id: String) -> Int {
        var completedDaysCount = 0
        completedTrackers.forEach {
            if $0.trackerID == id { completedDaysCount += 1 }
        }
        return completedDaysCount
    }
    
    private func getTracker(for indexPath: IndexPath) -> Tracker {
        isFiltering ? filteredCategories[indexPath.section].trackers[indexPath.row] : visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    private func showVisibleTrackers() {
        visibleCategories = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let date = dateFormatter.string(from: currentDate)
       
        var newCategories: [TrackerCategory] = []
        
        for (index, category) in categories.enumerated() {
            var trackers: [Tracker] = []
            for tracker in category.trackers {
                guard let weekDays = tracker.schedule else { return }
                for weekDay in weekDays {
                    if weekDay == date {
                        trackers.append(tracker)
                    } else {
                        continue
                    }
                }
                guard !trackers.isEmpty else {
                    presentedViewController?.dismiss(animated: false, completion: nil)
                    plugView.isHidden = false
                    continue
                }
                
                let newCategory = TrackerCategory(title: category.title, trackers: trackers)
                
                if newCategories.contains(newCategory) {
                    let trackers = newCategory.trackers
                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
                    newCategories[index] = newTrackerCategory
                } else {
                    newCategories.append(newCategory)
                }
            }
        }
 
        visibleCategories = newCategories
        let plusIsHidden = visibleCategories.isEmpty ? false : true
        plugView.isHidden = plusIsHidden        
        collectionView.reloadData()
        presentedViewController?.dismiss(animated: false, completion: nil)
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
        isFiltering ? filteredCategories.count : visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filteredCategories[section].trackers.count : visibleCategories[section].trackers.count
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
        
        
        let tracker = getTracker(for: indexPath)
        let completedDayCount = getDayCount(for: tracker.id)
        var completed = false
        
        completedTrackers.forEach { trackerRecord in
            if trackerRecord.trackerID == tracker.id && trackerRecord.checkDate == currentDate {
                completed = true
            }
        }
           
        cell.config(tracker: tracker, completedDaysCount: completedDayCount, completed: completed)
        cell.enabledCheckTrackerButton(enabled: today < currentDate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.reuseIdentifire, for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        let title: String
        
        if isFiltering {
            title = filteredCategories[indexPath.section].title
        } else {
            title = visibleCategories[indexPath.section].title
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
                }
            }
            showVisibleTrackers()
            dismiss(animated: true)
            return
        }
        
        categories.append(trackerCategory)
        if !categories.isEmpty { plugView.isHidden = true }
        showVisibleTrackers()
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
            filteredCategories = []
        } else {
            filterContentForSearchText(searchController.searchBar.text)
        }
    }
    
    private func filterContentForSearchText (_ searchText: String?) {
        guard let searchText else { return }
        
        // TODO: сделать поиск
        
        if filteredCategories.isEmpty && searchText != "" {
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
        filteredCategories = []
        let plusIsHidden = categories.isEmpty ? false : true
        plugView.isHidden = plusIsHidden
        plugView.config(title: TrackersListControllerConstants.plugLabelText, image: UIImage(named: "plug"))
        collectionView.reloadData()
    }
}


