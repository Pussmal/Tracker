import UIKit

final class FilterCollectionViewProvider: NSObject {
    private func configCellLayer(at indexPath: IndexPath, cell: FilterCollectionViewCell) {
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if indexPath.row == Constants.filterTitleArray.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.hideLineView()
        }
    }
}

extension FilterCollectionViewProvider: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterCollectionViewCell.cellReuseIdentifier,
            for: indexPath
        ) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
      
        let filterLabelText = Constants.filterTitleArray[safe: indexPath.row]
        configCellLayer(at: indexPath, cell: cell)
        cell.config(filterLabelText: filterLabelText, checkmarkIsHidden: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.filterTitleArray.count
    }
}

extension FilterCollectionViewProvider: UICollectionViewDelegateFlowLayout {
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

