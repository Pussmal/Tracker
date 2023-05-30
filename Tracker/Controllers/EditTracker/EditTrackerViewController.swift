import UIKit

protocol EditTrackerViewControllerDelegate: AnyObject {
    func dismissEditTrackerViewController(_ viewController: UIViewController)
}

enum EditTypeTracker {
    case editHabit
    case editEvent
}

final class EditTrackerViewController: UIViewController {
    
    // MARK: public properties
    weak var delegate: EditTrackerViewControllerDelegate?
    
    private struct ViewControllerConstants {
        static let editHabitTitle = "Редактирование привычки"
        static let editEventTitle = "Редактирование нерегулярного события"
    }
    
    // MARK: private properties
    private var editTypeTracker: EditTypeTracker
    private var selectedCategory: TrackerCategoryCoreData
    private var stringDatesArray: [String]?
    private var selectedDay: Date
    
    private var isHabit: Bool {
        switch editTypeTracker {
        case .editHabit:
            return true
        case .editEvent:
            return false
        }
    }
    
    private var stringSelectedDates: String {
        if stringDatesArray?.count == 7 {
            return "Каждый день"
        } else {
            return stringDatesArray?.joined(separator: ", ") ?? ""
        }
    }
    
    private let editTracker: EditTracker
    private let dataProvider = DataProvider()
    
    // MARK: UI
    private var editTrackerView: EditTrackerView!
    
    //MARK: initialization
    init(editTypeTracker: EditTypeTracker, editTracker: EditTracker, selectedCategory: TrackerCategoryCoreData, selectedDay: Date) {
        self.editTypeTracker = editTypeTracker
        self.editTracker = editTracker
        self.selectedCategory = selectedCategory
        self.selectedDay = selectedDay
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTrackerView = EditTrackerView(
            frame: view.bounds,
            editTypeTracker: editTypeTracker,
            editTracker: editTracker
        )
        editTrackerView.delegate = self
        
        stringDatesArray = editTracker.schedule.components(separatedBy: ",")
        editTrackerView.setCategory(with: editTracker.categoryTitle)
        editTrackerView.setSchedule(with: editTracker.schedule)
        editTrackerView.setEmoji(emoji: editTracker.tracker.emoji)
        editTrackerView.setSelectedTrackerColor(color: editTracker.tracker.color)
        
        switch editTypeTracker {
        case .editHabit:
            setupView(with: ViewControllerConstants.editHabitTitle)
        case .editEvent:
            setupView(with: ViewControllerConstants.editEventTitle)
        }
    }
    
    // MARK: private methods
    private func setupView(with title: String) {
        view.backgroundColor = .clear
        self.title = title
        addScreenView(view: editTrackerView)
    }
    
    deinit {
        print("CreateTrackerViewController deinit")
    }
}

// MARK: EditTrackerViewDelegate
extension EditTrackerViewController: EditTrackerViewDelegate {
    func sendTrackerSetup(nameTracker: String?, color: UIColor, emoji: String, isChecked: Bool) {
        if editTypeTracker == .editEvent {
            stringDatesArray = WeekDays.allCases.map({ $0.day.shortForm })
        }
        
        guard let nameTracker, stringDatesArray != nil else { return }
        
        let newTracker = Tracker(
            id: editTracker.tracker.id,
            name: nameTracker,
            color: color,
            emoji: emoji,
            schedule: stringDatesArray,
            isHabit: isHabit
        )
        
        try? dataProvider.resaveTracker(
            at: editTracker.indexPath,
            newTracker: newTracker,
            category: selectedCategory)
        
        dataProvider.checkTracker(trackerId: newTracker.id, completed: isChecked, with: selectedDay)
        delegate?.dismissEditTrackerViewController(self)
    }
    
    func showSchedule() {
        let viewController = createViewController(type: .schedule)
        present(viewController, animated: true)
    }
    
    func showCategory() {
        let viewController = createViewController(type: .category)
        present(viewController, animated: true)
    }
    
    func cancelCreate() {
        delegate?.dismissEditTrackerViewController(self)
    }
    
    private func setSelectedCategory() {
        editTrackerView.setCategory(with: selectedCategory.title)
    }
}

// MARK: create CategoryViewController
extension EditTrackerViewController {
    private func createViewController(type: ScheduleCategory) -> UINavigationController {
        let viewController: UIViewController
        
        switch type {
        case .schedule:
            let scheduleViewController = SheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.setSchedule(with: stringSelectedDates)
            viewController = scheduleViewController
        case .category:
            let viewModel = CategoriesViewControllerViewModel()
            let categoryViewController = CategoriesViewController(viewModel: viewModel)
            categoryViewController.delegate = self
            viewController = categoryViewController
            categoryViewController.selectedCategoryTitle = selectedCategory.title
        }
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

// MARK: CategoriesViewControllerDelegate
extension EditTrackerViewController: CategoriesViewControllerDelegate {
    func setCategory(categoryCoreData: TrackerCategoryCoreData?) {
        guard let categoryCoreData else { return }
        self.selectedCategory = categoryCoreData
        editTrackerView.setCategory(with: categoryCoreData.title)
        dismiss(animated: true)
    }
}

// MARK: ScheduleViewControllerDelegate
extension EditTrackerViewController: ScheduleViewControllerDelegate {
    func setSelectedDates(dates: [WeekDays]) {
        stringDatesArray = dates.map({ $0.day.shortForm })
        editTrackerView.setSchedule(with: stringSelectedDates)
        dismiss(animated: true)
    }
}
