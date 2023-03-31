import UIKit

final class CreateTrackerViewController: UIViewController {
    
    public var typeTracker: TypeTracker?
    
    private enum SheduleCategory {
        case shedule
        case category
    }
    
    private struct CreateTrackerViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
    }
    
    private var createTrackerView: CreateTrackerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard let typeTracker else {
            dismiss(animated: true)
            return
        }
        
        createTrackerView = CreateTrackerView(
            frame: view.bounds,
            delegate: self,
            typeTracker: typeTracker
        )
        
        switch typeTracker {
        case .Habit:
            setupView(with: CreateTrackerViewControllerConstants.habitTitle)
        case .Event:
            setupView(with: CreateTrackerViewControllerConstants.eventTitle)
        }
    }
    
    private func setupView(with title: String) {
        view.backgroundColor = .clear
        self.title = title
        addScreenView(view: createTrackerView)
    }
    
    deinit {
        print("CreateTrackerViewController deinit")
    }
    
}

extension CreateTrackerViewController: CreateTrackerViewDelegate {
    func showShedule() {
        let viewController = createViewController(type: .shedule)
        present(viewController, animated: true)
    }
    
    func showCategory() {
        let viewController = createViewController(type: .category)
        present(viewController, animated: true)
    }
    
    func createTracker() {
        print("Создаем tracker")
    }
    
    func cancelCreate() {
        print("Отмена")
    }
}


// MARK: create CategoryViewController
extension CreateTrackerViewController {
    private func createViewController(type: SheduleCategory) -> UINavigationController {
        let viewController: UIViewController
        
        switch type {
        case .shedule:
            viewController = SheduleViewController()
        case .category:
            viewController = CategoryViewController()
        }
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

