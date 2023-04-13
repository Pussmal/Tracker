import UIKit

protocol SheduleCollectionViewCellHelperDelegate: AnyObject {
   
}

final class SheduleCollectionViewCellHelper: NSObject {
    
    weak var delegate: SheduleCollectionViewCellHelperDelegate?
    
    private enum WeekDays: String, CaseIterable {
        case monday = "Понедельник"
        case tuesday = "Вторник"
        case wednesday = "Среда"
        case thursday = "Четверг"
        case friday = "Пятница"
        case saturday = "Суббота"
        case sunday = "Воскресенье"
    }
    
    init(delegate: SheduleCollectionViewCellHelperDelegate?) {
        self.delegate = delegate
    }
}

extension SheduleCollectionViewCellHelper: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SheduleCollectionViewCell.reuseIdentifire,
            for: indexPath
        ) as? SheduleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.config(day: WeekDays.allCases[indexPath.row].rawValue)
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if indexPath.row == WeekDays.allCases.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.hideLineView()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        WeekDays.allCases.count
    }
}

extension SheduleCollectionViewCellHelper: UICollectionViewDelegate {}

extension SheduleCollectionViewCellHelper: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - Constants.indentationFromEdges * 2
        return CGSize(width: width, height: Constants.hugHeight)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
}
