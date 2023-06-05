import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
}

enum ScheduleCategory {
    case schedule
    case category
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: public properties
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    //MARK: Helpres
    private struct ViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
    }
    
    // MARK: private properties
    private var typeTracker: TypeTracker
    private var selectedCategory: TrackerCategoryCoreData?
    private var datesArray: [String] = []
    
    private var isHabit: Bool {
        switch typeTracker {
        case .habit:
            return true
        case .event:
            return false
        }
    }
        
    private var tracker: Tracker?
    private let dataProvider: DataProviderProtocol
    
    // MARK: UI
    private var createTrackerView: CreateTrackerView!
    
    //MARK: initialization
    init(typeTracker: TypeTracker, dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.typeTracker = typeTracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTrackerView = CreateTrackerView(
            frame: view.bounds,
            delegate: self,
            typeTracker: typeTracker
        )
        
        switch typeTracker {
        case .habit:
            setupView(with: ViewControllerConstants.habitTitle)
        case .event:
            setupView(with: ViewControllerConstants.eventTitle)
        }
    }
    
    // MARK: private methods
    private func setupView(with title: String) {
        view.backgroundColor = .clear
        self.title = title
        addScreenView(view: createTrackerView)
    }
    
    deinit {
        print("CreateTrackerViewController deinit")
    }
}

// MARK: CreateTrackerViewDelegate
extension CreateTrackerViewController: CreateTrackerViewDelegate {
    func sendTrackerSetup(nameTracker: String?, color: UIColor, emoji: String) {
        if typeTracker == .event { datesArray = Constants.allWeekDayStringIndexArray }
        guard
            let nameTracker,
            !datesArray.isEmpty
        else { return }
        
        tracker = Tracker(
            id: UUID().uuidString,
            name: nameTracker,
            color: color,
            emoji: emoji,
            schedule: datesArray,
            isHabit: isHabit,
            isPinned: false,
            idCategory: nil
        )
        
        guard let tracker = tracker,
              let selectedCategory
        else { return }
        
        try? dataProvider.saveTracker(tracker, in: selectedCategory)
        delegate?.dismissViewController(self)
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
        delegate?.dismissViewController(self)
    }
}

// MARK: create CategoryViewController
extension CreateTrackerViewController {
    private func createViewController(type: ScheduleCategory) -> UINavigationController {
        let viewController: UIViewController
        
        switch type {
        case .schedule:
            let sheduleViewController = SheduleViewController()
            sheduleViewController.delegate = self
            viewController = sheduleViewController
        case .category:
            let viewModel = CategoriesViewControllerViewModel()
            let categoryViewController = CategoriesViewController(viewModel: viewModel)
            categoryViewController.delegate = self
            viewController = categoryViewController
            
            if let selectedCategory {
                categoryViewController.selectedCategoryTitle = selectedCategory.title
            }
        }
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

// MARK: CategoriesViewControllerDelegate
extension CreateTrackerViewController: CategoriesViewControllerDelegate {
    func setCategory(categoryCoreData: TrackerCategoryCoreData?) {
        self.selectedCategory = categoryCoreData
        createTrackerView.setCategory(with: categoryCoreData?.title)
        dismiss(animated: true)
    }
}

// MARK: SheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func setSelectedDates(dates: [Int]) {
        datesArray = dates.map({ String($0) })
        let stringDatesArray = dates.map({
            var dayNumber = $0 + 1
            if dayNumber == 7 {
                dayNumber = 0
            }
            return Calendar.current.shortWeekdaySymbols[dayNumber]
        })
        
        var stringSelectedDates: String
        if stringDatesArray.count == 7 {
            stringSelectedDates = Constants.stringForCheckedDay
        } else {
            stringSelectedDates = stringDatesArray.joined(separator: ", ")
        }
        
        createTrackerView.setSchedule(with: stringSelectedDates)
        dismiss(animated: true)
    }
}
