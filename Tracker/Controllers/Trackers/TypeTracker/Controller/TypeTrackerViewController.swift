import UIKit

enum TypeTracker {
    case Habit
    case Event
}

protocol TypeTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
    func createTrackerCategory(_ trackerCategory: TrackerCategory?)
}

final class TypeTrackerViewController: UIViewController {
    
    private var typeTrackerView: TypeTrackerView!
    
    weak var delegate: TypeTrackerViewControllerDelegate?
    
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
        viewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

extension TypeTrackerViewController: CreateTrackerViewControllerDelegate {
    func creatTrackerCategory(_ trackerCategory: TrackerCategory?) {
        delegate?.createTrackerCategory(trackerCategory)
    }
    
    func dismissViewController(_ viewController: UIViewController) {
        delegate?.dismissViewController(viewController)
    }
}
