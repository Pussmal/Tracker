import UIKit

protocol SheduleCategoryCollectionViewHelperDelegate: AnyObject {
    func showCategory()
    func showShedule()
}

final class SheduleCategoryCollectionViewHelper: NSObject {
    
    private var typeTracker: TypeTracker
    private let cellsTitle = ["Категория", "Расписание"]
    
    weak var delegate: SheduleCategoryCollectionViewHelperDelegate?
    
    init(typeTracker: TypeTracker) {
        self.typeTracker = typeTracker
    }
}

extension SheduleCategoryCollectionViewHelper: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SheduleCategoryCollectionViewCell.reuseIdentifire,
            for: indexPath
        ) as? SheduleCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = Constants.cornerRadius
        
        switch typeTracker {
        case .Habit:
            addCornerRaduisForHabit(cell: cell, row: indexPath.row)
        case .Event:
            addCornerRaduisForEvent(cell: cell)
        }
        
        cell.config(category: cellsTitle[safe: indexPath.row])
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch typeTracker {
        case .Habit:
            return 2
        case .Event:
            return 1
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch indexPath.row {
        case 0:
            delegate?.showCategory()
        case 1:
            delegate?.showShedule()
        default:
            break
        }
    }
}

extension SheduleCategoryCollectionViewHelper: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - Constants.indentationFromEdges * 2
        return CGSize(width: width, height: Constants.hugHeight)
    }

    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}


extension SheduleCategoryCollectionViewHelper {
    private func addCornerRaduisForHabit(
        cell: SheduleCategoryCollectionViewCell,
        row: Int
    ) {
        if row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if row == cellsTitle.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.hideLineView()
        }
    }
    
    private func addCornerRaduisForEvent(
        cell: SheduleCategoryCollectionViewCell
    ) {
        cell.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        cell.hideLineView()
    }
}
