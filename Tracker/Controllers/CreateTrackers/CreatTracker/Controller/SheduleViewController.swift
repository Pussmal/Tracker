import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func setSelectedDates(dates: [Int])
}

final class SheduleViewController: UIViewController {

    private var sheduleView: SheduleView!
   
    weak var delegate: ScheduleViewControllerDelegate?
    
    private struct ViewControllerConstants {
        static let title = "Расписание"
    }
    
    private var selectedDays: [String] = []
    
    func setSchedule(with schedule: String) {
        selectedDays = schedule.components(separatedBy: ",")
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
        title =  ViewControllerConstants.title
        view.backgroundColor = .clear
        addScreenView(view: sheduleView)
    }
    
    deinit {
        print("SheduleViewController deinit")
    }
}

extension SheduleViewController: SheduleViewDelegate {
    func setDates(dates: [Int]?) {
        guard let dates, !dates.isEmpty else { return }
        delegate?.setSelectedDates(dates: dates)
    }
}
