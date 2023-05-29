import UIKit

final class SheduleCollectionViewCellHelper: NSObject {
    private(set) var selectedDates: Set<WeekDays> = []
    private var selectedDays: [String] = []
        
    private func configCellLayer(at indexPath: IndexPath, cell: SheduleCollectionViewCell) {
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
        configCellLayer(at: indexPath, cell: cell)
        let cellDay = WeekDays.allCases[indexPath.row].rawValue
        cell.config(day: cellDay)
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        WeekDays.allCases.count
    }
}

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

extension SheduleCollectionViewCellHelper: SheduleCollectionViewCellProtocol {
    func getSelectedDay(_ indexPath: IndexPath?, select: Bool) {
        guard let indexPath else { return }
        let day = WeekDays.allCases[indexPath.row]
        
        if select {
            selectedDates.insert(day)
        } else {
            selectedDates.remove(day)
        }
    }
}
