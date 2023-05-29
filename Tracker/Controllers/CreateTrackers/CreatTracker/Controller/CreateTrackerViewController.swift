import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
}

enum SheduleCategory {
    case shedule
    case category
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: public properties
    weak var delegate: CreateTrackerViewControllerDelegate?
        
    private struct ViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
    }
    
    // MARK: private properties
    private var typeTracker: TypeTracker
    private var selectedCategory: TrackerCategoryCoreData?
    private var stringDatesArray: [String]?
    
    private var isHabit: Bool {
        switch typeTracker {
        case .habit:
            return true
        case .event:
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
    
    private var tracker: Tracker?
    private let dataProvider = DataProvider()
    
    // MARK: UI
    private var createTrackerView: CreateTrackerView!
    
    //MARK: initialization
    init(typeTracker: TypeTracker) {
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
        if typeTracker == .event {
            stringDatesArray = WeekDays.allCases.map({ $0.day.shortForm })
        }
    
        guard
            let nameTracker,
            stringDatesArray != nil
        else { return }
            
        tracker = Tracker(
            id: UUID().uuidString,
            name: nameTracker,
            color: color,
            emoji: emoji,
            schedule: stringDatesArray,
            isHabit: isHabit
        )
                
        guard let tracker = tracker,
              let selectedCategory
        else { return }
        
        try? dataProvider.saveTracker(tracker, in: selectedCategory)
        delegate?.dismissViewController(self)
    }
    
    func showSchedule() {
        let viewController = createViewController(type: .shedule)
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
    private func createViewController(type: SheduleCategory) -> UINavigationController {
        let viewController: UIViewController
        
        switch type {
        case .shedule:
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
    func setSelectedDates(dates: [WeekDays]) {
        stringDatesArray = dates.map({ $0.day.shortForm })
        createTrackerView.setShedule(with: stringSelectedDates)
        dismiss(animated: true)
    }
}
