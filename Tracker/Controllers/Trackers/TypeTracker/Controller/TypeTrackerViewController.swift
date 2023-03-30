import UIKit

enum TypeTracker {
    case Habit
    case Event
}

final class TypeTrackerViewController: UIViewController {
    
    private var typeTrackerView: TypeTrackerView!
    
    private struct TypeTrackerViewControllerConstants {
        static let viewControllerTitle = "Создание трекера"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeTrackerView = TypeTrackerView(frame: .zero, delegate: self)
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = TypeTrackerViewControllerConstants.viewControllerTitle
        addScreenView(view: typeTrackerView)
    }
    
    deinit {
        print("TypeTrackerViewController deinit")
    }
}

// MARK: TypeTrackerViewDelegate
extension TypeTrackerViewController: TypeTrackerViewDelegate {
    func showIirregularEvents() {
        let viewController = createTrackerViewController(typeTracker: .Event)
        present(viewController, animated: true)
    }
    
    func showHabit() {
        let viewController = createTrackerViewController(typeTracker: .Habit)
        present(viewController, animated: true)
    }
}

// MARK: create TrackerViewController
extension TypeTrackerViewController {
    private func createTrackerViewController(typeTracker: TypeTracker) -> UINavigationController {
        let viewController = CreateTrackerViewController()
        viewController.typeTracker = typeTracker
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}
