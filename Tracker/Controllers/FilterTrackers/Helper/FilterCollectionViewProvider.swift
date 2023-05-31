import UIKit

protocol FilterCollectionViewProviderDelegate: AnyObject {
    func getTrackerWithFilter(_ newFilter: FilterType)
}

protocol FilterCollectionViewProviderProtocol: AnyObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func setFilter(selectedFilter: FilterType)
}

final class FilterCollectionViewProvider: NSObject {
    
    weak var delegate: FilterCollectionViewProviderDelegate?
    private var selectedFilter: FilterType?
    
    private func configCellLayer(at indexPath: IndexPath, cell: FilterCollectionViewCell) {
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if indexPath.row == FilterType.allCases.count - 1 {
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
        ) as? FilterCollectionViewCell,
        let selectedFilter else {
            return UICollectionViewCell()
        }
      
        let checkmarkIsHidden = selectedFilter == FilterType.allCases[safe: indexPath.row]
        let filterLabelText = FilterType.allCases[safe: indexPath.row]?.filterTitle
        configCellLayer(at: indexPath, cell: cell)
        cell.config(filterLabelText: filterLabelText, checkmarkIsHidden: checkmarkIsHidden)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        FilterType.allCases.count
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

extension FilterCollectionViewProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let newFilter = FilterType.allCases[safe: indexPath.row] else { return }
        delegate?.getTrackerWithFilter(newFilter)
    }
}

extension FilterCollectionViewProvider: FilterCollectionViewProviderProtocol {
    func setFilter(selectedFilter: FilterType) {
        self.selectedFilter = selectedFilter
    }
}
