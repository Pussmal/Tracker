import UIKit

final class SheduleCategoryTableViewHelper: NSObject {
    
    private var typeTracker: TypeTracker
    private let cellsTitle = ["Категория", "Расписание"]
    
    init(typeTracker: TypeTracker) {
        self.typeTracker = typeTracker
    }
    
    private func cellConfig(cell: UITableViewCell) {
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.ypRegularSize17
        cell.detailTextLabel?.font = UIFont.ypRegularSize17
        cell.detailTextLabel?.textColor = .ypGray
        cell.backgroundColor = .ypBackground
    }
}

extension SheduleCategoryTableViewHelper: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.hugHeight
    }
}

extension SheduleCategoryTableViewHelper: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeTracker {
        case .Habit:
            return 2
        case .Event:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cellConfig(cell: cell)
        cell.textLabel?.text = cellsTitle[safe: indexPath.row]
        cell.detailTextLabel?.text = "Хрень"
        return cell
    }
}
