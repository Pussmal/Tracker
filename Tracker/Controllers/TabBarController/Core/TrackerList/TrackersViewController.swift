import UIKit

enum ShowTrackers {
    case isCompleted
    case isNotComplited
    case isAllTrackers
}

final class TrackersViewController: UIViewController {
    
    // MARK: Constants
    private struct ViewControllerConstants {
        static let addTrackerButtonImageName = "plus"
        static let reuseIdentifierCell = "cell"
        static let cancelButtonTextKey = "cancelButtonText"
        static let searchBarPlaceholderText = NSLocalizedString("SearchBarPlaceholderText", comment: "Text for searchBar's placeholder")
        static let searchBarCancelButtonText = NSLocalizedString("SearchBarCancelButtonText", comment: "Text for searchBar's cancel button")
        static let deleteActionSheetMessage = NSLocalizedString("deleteActionSheetMessage", comment: "Text for action sheep title")
        static let deleteActionTitle = NSLocalizedString("deleteActionTitle", comment: "Text for action sheep delete button")
        static let cancelActionSheetButtonTitle = NSLocalizedString("cancelActionSheetButtonTitle", comment: "Text for action sheep cancel button")
        static let editActionTitle = NSLocalizedString("editActionTitle", comment: "Edit title for UIContextmenu")
        static let filterButtonTitle = NSLocalizedString("filterTitle", comment: "Title for filter button")
    }
    
    // MARK: private properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var dataProvider: DataProviderProtocol
    private var selectedFilter: FilterType = .trackersForToday // by default
    private var showTrackers: ShowTrackers = .isAllTrackers // by default
    private var completedTracker: [Tracker] = []
    private var nonCompletedTracker: [Tracker] = []
    
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
        let imageButton = UIImage(named: ViewControllerConstants.addTrackerButtonImageName)
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
        picker.locale = .current
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
            forCellWithReuseIdentifier: ViewControllerConstants.reuseIdentifierCell
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
        let plugView = PlugView(frame: .zero, plug: .trackers)
        plugView.alpha = 0
        return plugView
    }()
    
    private lazy var filterButton: TrackerButton = {
        let button = TrackerButton(frame: .zero, title: ViewControllerConstants.filterButtonTitle)
        button.backgroundColor = .ypBlue
        button.setTitleColor(.white, for: .normal)
        button.alpha = 0
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - initialization
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addSubviews()
        activateConstraints()
        setupSearchController()
        
        dataProvider.delegate = self
        
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSubviews() {
        view.addSubViews(collectionView, plugView, filterButton)
    }
    
    private func activateConstraints() {
        let filterButtonWidth: CGFloat = 114
        let filterButtonHeight: CGFloat = 50
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: filterButtonWidth),
            filterButton.heightAnchor.constraint(equalToConstant: filterButtonHeight),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ViewControllerConstants.searchBarPlaceholderText
        searchController.delegate = self
        searchController.searchBar.setValue(
            ViewControllerConstants.searchBarCancelButtonText,
            forKey: ViewControllerConstants.cancelButtonTextKey
        )
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func checkPlugView() {
        // если трекеров в базе нет, показываем заглушку что будем искать? если есть трекеры показываем заглушку не найдено и кнопку фильтрации
        guard dataProvider.isTrackersInCoreData else {
            plugView.config(plug: .trackers)
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.filterButton.alpha = 0
                self.plugView.alpha = 1
            }
            plugView.isHidden = false
            return
        }
        
        plugView.config(plug: .search)
        filterButton.alpha = 1
        plugView.alpha = dataProvider.isTrackersForSelectedDate ? 1 : 0
    }
    
    @objc
    private func addTrackerButtonTapped() {
        showTypeTrackerViewController()
    }
    
    @objc
    private func changedDate() {
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    @objc
    private func filterButtonTapped() {
        filterButton.showAnimation { [weak self] in
            guard let self else { return }
            self.showFilterViewController()
        }
    }
    
    private func showFilterViewController() {
        let filterProvider = FilterCollectionViewProvider()
        filterProvider.delegate = self
        let viewController = FiltersViewController(selectedFilter: selectedFilter, provider: filterProvider)
        let navigationViewController = UINavigationController(rootViewController: viewController)
        present(navigationViewController, animated: true)
    }
    
    private func getDayCountAndDayCompleted(for trackerId: String) -> (count: Int, completed: Bool) {
        let count = dataProvider.getCompletedDayCount(from: trackerId)
        let completed = dataProvider.getCompletedDay(from: trackerId, currentDay: datePicker.date)
        return (count, completed)
    }
    
    private func editTracker(at tracker: Tracker, category: TrackerCategoryCoreData, indexPath: IndexPath) {
        let editTypeTracker: EditTypeTracker = tracker.isHabit ? .editHabit : .editEvent
        let countAndCompleted = getDayCountAndDayCompleted(for: tracker.id)
        let schedule = getSchedule(for: tracker.schedule)
        let editTracker = EditTracker(
            tracker: tracker,
            categoryTitle: category.title ?? "",
            schedule: schedule,
            checkCountDay: countAndCompleted.count,
            isChecked: countAndCompleted.completed,
            canCheck: Date() < datePicker.date,
            indexPath: indexPath
        )
        let viewController = EditTrackerViewController(
            editTypeTracker: editTypeTracker,
            editTracker: editTracker,
            selectedCategory: category,
            selectedDay: datePicker.date
        )
        viewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: viewController)
        present(navigationViewController, animated: true)
    }
    
    private func showActionSheepForDeleteTracker(trackerIndexPath: IndexPath) {
        var deleteActionSheet: UIAlertController {
            let message = ViewControllerConstants.deleteActionSheetMessage
            let alertController = UIAlertController(
                title: nil, message: message,
                preferredStyle: .actionSheet
            )
            let deleteAction = UIAlertAction(
                title: ViewControllerConstants.deleteActionTitle,
                style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    do {
                        try self.dataProvider.deleteTracker(at: trackerIndexPath)
                        self.collectionView.reloadData()
                        self.checkPlugView()
                    } catch {
                        assertionFailure("Error delete tracker")
                    }
                }
            let cancelAction = UIAlertAction(title: ViewControllerConstants.cancelActionSheetButtonTitle, style: .cancel)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            return alertController
        }
        
        let viewController = deleteActionSheet
        present(viewController, animated: true)
    }
    
    private func getSchedule(for arraySchedule: [String]?) -> String {
        guard let arraySchedule else { return "" }
        guard arraySchedule.count <= 6 else { return Constants.stringForCheckedDay }
        
        let numberDay = arraySchedule.compactMap { Int($0) }
        let shortWeekday = Calendar.current.shortWeekdaySymbols
        var scheduleArray: [String] = []
        
        // чтобы первый день был понедельник
        numberDay.forEach {
            var index = $0 + 1
            if index > 6 { index = 0 }
            scheduleArray.append(shortWeekday[index])
        }
        
        return scheduleArray.joined(separator: ", ")
    }
    
    private func pinTracker(tracker: Tracker, category: TrackerCategoryCoreData, indexPath: IndexPath) {
        let pinnedTracker = PinnedTracker(
            tracker: tracker,
            idOldCategory: category.idCategory ?? "",
            trackerIndexPath: indexPath
        )
        dataProvider.setPinnedCategory(tracker: pinnedTracker)
        collectionView.reloadData()
    }
    
    private func unpinTracker(tracker: Tracker, category: TrackerCategoryCoreData, indexPath: IndexPath) {
        let pinnedTracker = PinnedTracker(
            tracker: tracker,
            idOldCategory: tracker.idCategory ?? "",
            trackerIndexPath: indexPath
        )
        dataProvider.unpinnedTracker(tracker: pinnedTracker)
        collectionView.reloadData()
    }
    
    private func loadTrackers(with showTrackers: ShowTrackers, date: Date, filterString searchText: String?) {
        try? dataProvider.loadTrackers(from: date, showTrackers: showTrackers, with: searchText)
    }
         
}

// MARK: UICollectionViewDelegateFlowLayout
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

// MARK: UICollectionViewDataSource
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
        else { return UICollectionViewCell() }
        
        let countAndCompleted = getDayCountAndDayCompleted(for: tracker.id)
    
        cell.config(
            tracker: tracker,
            completedDaysCount: countAndCompleted.count,
            completed: countAndCompleted.completed,
            isPinned: tracker.isPinned
        )
        cell.enabledCheckTrackerButton(enabled: today < currentDate)
        cell.delegate = self
        cell.interaction = UIContextMenuInteraction( delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderReusableView.reuseIdentifier,
            for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        // у нас есть дефолтная (скрытая) категория "Закрепленные", этим условием устанавливаем для нее title если она отображается, в остальных случаем тащим title из БД
        let categoryTitle = dataProvider.getSectionTitle(at: indexPath.section)
        
        guard let categoryTitle, categoryTitle != Constants.pinnedCategory else {
            let pinnedCategoryTitle = NSLocalizedString("pinnedCategory", comment: "")
            view.config(title: pinnedCategoryTitle)
            return view
        }
        
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

// MARK: TypeTrackerViewControllerDelegate
extension TrackersViewController: TypeTrackerViewControllerDelegate {
    func dismissViewController(_ viewController: UIViewController) {
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        dismiss(animated: true)
    }
}

// MARK: TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker(id: String?, completed: Bool) {
        dataProvider.checkTracker(trackerId: id, completed: completed, with: datePicker.date)
    }
}

// MARK: UISearchResultsUpdating, UISearchControllerDelegate
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != "" else { return }
        filterContentForSearchText(searchController.searchBar.text)
    }
    
    private func filterContentForSearchText (_ searchText: String?) {
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: searchText)
        guard !dataProvider.isTrackersForSelectedDate && searchText != "" else { return }
        plugView.isHidden = false
        plugView.config(plug: .search)
    }
}

// MARK: UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        checkPlugView()
        plugView.config(plug: .trackers)
        collectionView.reloadData()
    }
}

// MARK: DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func didUpdate() {
        checkPlugView()
        collectionView.reloadData()
    }
}

extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let location = interaction.view?.convert(location, to: collectionView),
              let indexPath = collectionView.indexPathForItem(at: location),
              let tracker =  dataProvider.getTracker(at: indexPath),
              let category = dataProvider.getTrackersCategory(atTrackerIndexPath: indexPath)
        else { return UIContextMenuConfiguration() }
        
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard let self else { return UIMenu() }
            
            var pinActionTitle: String
            
            if tracker.isPinned {
                pinActionTitle = NSLocalizedString("toUnpinTracker", comment: "")
            } else {
                pinActionTitle = NSLocalizedString("toPinTracker", comment: "")
            }
            
            return UIMenu(children: [
                UIAction(title: pinActionTitle) {  [weak self] _ in
                    guard let self else { return }
                    if tracker.isPinned {
                        self.unpinTracker(tracker: tracker, category: category, indexPath: indexPath)
                    } else {
                        self.pinTracker(tracker: tracker, category: category, indexPath: indexPath)
                    }
                },
                UIAction(title: ViewControllerConstants.editActionTitle) { [weak self] _ in
                    guard let self else { return }
                    self.editTracker(at: tracker, category: category, indexPath: indexPath)
                },
                UIAction(
                    title: ViewControllerConstants.deleteActionTitle,
                    attributes: .destructive,
                    handler: { [weak self] _ in
                        guard let self else { return }
                        self.showActionSheepForDeleteTracker(trackerIndexPath: indexPath)
                    } )
            ])
        })
    }
}

extension TrackersViewController: EditTrackerViewControllerDelegate {
    func dismissEditTrackerViewController(_ viewController: UIViewController) {
        checkPlugView()
        collectionView.reloadData()
        dismissViewController(viewController)
    }
}

extension TrackersViewController: FilterCollectionViewProviderDelegate {
    func getTrackerWithFilter(_ newFilter: FilterType) {
        selectedFilter = newFilter
        switch newFilter {
        case .allTrackers:
            showAllTrackerForCurrentDay()
        case .trackersForToday:
            showTrackersForToday()
        case .completed:
            showCompletedTrackerForCurrentDay()
        case .notCompleted:
            showNonCompletedTrackerForCurrentDay()
        }
        dismissViewController(self)
    }
}

// MARK: Filter methods
extension TrackersViewController {
    func showAllTrackerForCurrentDay() {
        showTrackers = .isAllTrackers
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        collectionView.reloadData()
    }
    
    func showTrackersForToday() {
        showTrackers = .isAllTrackers
        loadTrackers(with: showTrackers, date: today, filterString: nil)
        datePicker.date = Date()
        collectionView.reloadData()
    }
    
    func showCompletedTrackerForCurrentDay() {
        showTrackers = .isCompleted
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        collectionView.reloadData()
    }
    
    func showNonCompletedTrackerForCurrentDay() {
        showTrackers = .isNotComplited
        loadTrackers(with: showTrackers, date: datePicker.date, filterString: nil)
        collectionView.reloadData()
    }
}
