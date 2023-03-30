import UIKit

final class ColorsCollectionViewHelper: NSObject {
    private let colors = [
        UIColor.ypColorSelection1,
        UIColor.ypColorSelection2,
        UIColor.ypColorSelection3,
        UIColor.ypColorSelection4,
        UIColor.ypColorSelection5,
        UIColor.ypColorSelection6,
        UIColor.ypColorSelection7,
        UIColor.ypColorSelection8,
        UIColor.ypColorSelection9,
        UIColor.ypColorSelection10,
        UIColor.ypColorSelection11,
        UIColor.ypColorSelection12,
        UIColor.ypColorSelection13,
        UIColor.ypColorSelection14,
        UIColor.ypColorSelection15,
        UIColor.ypColorSelection16,
        UIColor.ypColorSelection17,
        UIColor.ypColorSelection18,
    ].compactMap { color in
        if let color { return color }
        return nil
    }
    
    private let title = "Цвет"
}

extension ColorsCollectionViewHelper: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionViewCell.reuseIdentifire,
            for: indexPath
        ) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.config(color: colors[safe: indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderReusableView.reuseIdentifire,
                for: indexPath) as? HeaderReusableView
        else {
            return UICollectionReusableView()
        }
        view.config(title: title)
        return view
    }
}

extension ColorsCollectionViewHelper: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
        cell?.showBorderCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
        cell?.hideBorderCell()
    }
}

extension ColorsCollectionViewHelper: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - (Constants.indentationFromEdges * 2)) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 9
        
        return CGSize(width: width, height: height)
    }
}
