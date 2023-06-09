import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    private struct TrackersListControllerConstants {
        static let viewControllerTitle = "Трекеры"
        static let plugLabelText = "Что будем отслеживать?"
        static let plugImageName = "plug"
        static let addTrackerButtonImageName = "plus"
        static let localeIdentifier = "ru_RU"
        static let reuseIdentifierCell = "cell"
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var dataProvider: DataProviderProtocol!
        
    private var currentDate: Date {
        let date = datePicker.date
        let currentDate = date.getDate
        return currentDate
    }
    
    private var today: Date {
        let date = Date()
        let today = date.getDate
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
        let imageButton = UIImage(named: TrackersListControllerConstants.addTrackerButtonImageName)?.withRenderingMode(.alwaysTemplate)
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
        picker.locale = Locale(identifier: TrackersListControllerConstants.localeIdentifier)
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
            forCellWithReuseIdentifier: TrackersListControllerConstants.reuseIdentifierCell
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifier)
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
            image: UIImage(named: TrackersListControllerConstants.plugImageName) ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider = DataProvider()
        
        setupView()
        addSubviews()
        activateConstraints()
        setupSearchController()
        
        dataProvider.delegate = self
        
        try? dataProvider.loadTrackers(from: datePicker.date, with: nil)
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
        title = TrackersListControllerConstants.viewControllerTitle
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSubviews() {
        view.addSubViews(collectionView, plugView)
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
        try? dataProvider.loadTrackers(from: datePicker.date, with: nil)
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    private func getDayCountAndDayCompleted(for trackerId: String) -> (count: Int, completed: Bool) {
        let count = dataProvider.getCompletedDayCount(from: trackerId)
        let completed = dataProvider.getCompletedDay(from: trackerId, currentDay: currentDate)
        return (count, completed)
    }
}

// MARK: UICollectionView
extension TrackersViewController: UICollectionViewDelegate {}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 44) / 2
        let heightConstant: CGFloat = 132
        let size = CGSize(width: width, height: heightConstant)
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
        dataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider.numberOfRowsInSection(section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell,
              let tracker = dataProvider.getTracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
        let countAndCompleted = getDayCountAndDayCompleted(for: tracker.id)
    
        cell.config(tracker: tracker, completedDaysCount: countAndCompleted.count, completed: countAndCompleted.completed)
        cell.enabledCheckTrackerButton(enabled: today < currentDate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        let categoryTitle = dataProvider.getSectionTitle(at: indexPath.section)
        view.config(title: categoryTitle)
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
        try? dataProvider.loadTrackers(from: datePicker.date, with: nil)
        dismiss(animated: true)
    }
}

// MARK: TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker(id: String?, completed: Bool) {
        dataProvider.checkTracker(for: id, completed: completed, with: currentDate)
    }
}

// MARK: UISearchResultsUpdating, UISearchControllerDelegate
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != ""  else { return }
        filterContentForSearchText(searchController.searchBar.text)
    }
    
    private func filterContentForSearchText (_ searchText: String?) {
        try? dataProvider.loadTrackers(from: datePicker.date, with: searchText)
    
        if !dataProvider.isTrackersForSelectedDate && searchText != "" {
            plugView.isHidden = false
            plugView.config(title: "Ничего не найдено", image: UIImage(named: "notFound"))
        }
    }
}

extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        try? dataProvider.loadTrackers(from: datePicker.date, with: nil)
        plugView.isHidden = dataProvider.isTrackersForSelectedDate ? true : false
        plugView.config(
            title: TrackersListControllerConstants.plugLabelText,
            image: UIImage(named: TrackersListControllerConstants.plugImageName)
        )
        collectionView.reloadData()
    }
}

// MARK: DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func didUpdate() {
        plugView.isHidden = dataProvider.isTrackersForSelectedDate ? true : false
        collectionView.reloadData()
    }
}
