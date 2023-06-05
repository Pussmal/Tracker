import UIKit

enum TypeTracker {
    case habit
    case event
}

protocol TypeTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
}

final class TypeTrackerViewController: UIViewController {

    weak var delegate: TypeTrackerViewControllerDelegate?
    
    private struct TypeTrackerViewControllerConstants {
        static let viewControllerTitle = NSLocalizedString("TypeTrackerViewControllerTitle", comment: "View Controller's title")
    }
    
    private var typeTrackerView: TypeTrackerView!
    
    
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
    func showEvent() {
        let viewController = createTrackerViewController(typeTracker: .event)
        present(viewController, animated: true)
    }
    
    func showHabit() {
        let viewController = createTrackerViewController(typeTracker: .habit)
        present(viewController, animated: true)
    }
}

// MARK: create TrackerViewController
extension TypeTrackerViewController {
    private func createTrackerViewController(typeTracker: TypeTracker) -> UINavigationController {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let dataProvider = DataProvider(context: context)
        let viewController = CreateTrackerViewController(typeTracker: typeTracker, dataProvider: dataProvider)
        viewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

extension TypeTrackerViewController: CreateTrackerViewControllerDelegate {    
    func dismissViewController(_ viewController: UIViewController) {
        delegate?.dismissViewController(viewController)
    }
}
