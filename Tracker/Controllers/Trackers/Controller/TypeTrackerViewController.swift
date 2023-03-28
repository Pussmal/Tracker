import UIKit

final class TypeTrackerViewController: UIViewController {

    private var typeTrackerView: TypeTrackerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeTrackerView = TypeTrackerView(frame: .zero, delegate: self)
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        addScreenView(view: typeTrackerView)
    }
}

// MARK: TypeTrackerViewDelegate
extension TypeTrackerViewController: TypeTrackerViewDelegate {
    func showIirregularEvents() {
        print("show showIirregularEventsVC")
    }
    
    func showHabit() {
        print("show habitVC")
    }

}
