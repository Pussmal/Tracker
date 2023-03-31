import UIKit

protocol CategoryCollectionViewCellHelperDelegate: AnyObject {
    func editCategory(editCategoryString: String?)
    func deleteCategory()
}

final class CategoryCollectionViewCellHelper: NSObject {
    
    weak var delegate: CategoryCollectionViewCellHelperDelegate?
    
    private let category = [
        "Важное", "Радостоные мелочи", "еще какая-то хрень"
    ]
    
    init(delegate: CategoryCollectionViewCellHelperDelegate?) {
        self.delegate = delegate
    }
    
    private func createContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self else { return }
                    print("Вызвать делегата и сказать чтобы редактировал категорию и передать в него категорию")
                    self.delegate?.editCategory(editCategoryString: self.category[safe: indexPath.row])
                },
                UIAction(title: "Удалить", attributes: .destructive, handler: {  [weak self] _ in
                    guard let self = self else { return }
                    print("Вызвать делегата и сказать чтобы удалил категорию и передать в него категорию")
                    self.delegate?.deleteCategory()
                })
            ])
        })
    }
}

extension CategoryCollectionViewCellHelper: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifire,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.config(category: category[safe: indexPath.row])

        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if indexPath.row == category.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.hideLineView()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        category.count
    }
}

extension CategoryCollectionViewCellHelper: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        cell?.didSelect()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        cell?.didDeselect()
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        return createContextMenu(indexPath: indexPath)
        
    }
}

extension CategoryCollectionViewCellHelper: UICollectionViewDelegateFlowLayout {
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
