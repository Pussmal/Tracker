import UIKit

final class SheduleViewController: UIViewController {

    private var sheduleView: SheduleView!
   
    
    private struct SheduleViewControllerConstants {
        static let title = "Расписание"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sheduleView = SheduleView(
            frame: view.bounds,
            delegate: self
        )
        setupView()
    }
    
    private func setupView() {
        title =  SheduleViewControllerConstants.title
        view.backgroundColor = .clear
        addScreenView(view: sheduleView)
    }
    
    deinit {
        print("SheduleViewController deinit")
    }
}

extension SheduleViewController: SheduleViewDelegate {
    func setDates() {
        print("определили даты")
    }
}
