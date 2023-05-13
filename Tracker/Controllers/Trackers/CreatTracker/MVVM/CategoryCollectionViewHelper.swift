//import UIKit
//
//protocol CategoryCollectionViewHelperDelegate: AnyObject {
//    func editCategory(editCategoryString: String?)
//    func deleteCategory(delete: String?)
//    //func updateCollectionView()
//    func selectCategory(category: String?)
//}
//
//final class CategoryCollectionViewHelper: NSObject {
//    
//    
//    static let didChangeNotification = Notification.Name(rawValue: "CategoryDidChange")
//    
//    private var editCategoryServiceObserver: NSObjectProtocol?
//    
//
//        
//    init(delegate: CategoryCollectionViewHelperDelegate?, oldCategory: String?) {
//        self.delegate = delegate
//        self.oldCategory = oldCategory
//        super.init()
//        registerObserver()
//    }
//    
//    private func registerObserver()  {
//        editCategoryServiceObserver = NotificationCenter.default
//            .addObserver(forName: EditCategoryView.didChangeNotification,
//                         object: nil,
//                         queue: .main,
//                         using: { [weak self] _ in
//                guard let self = self else { return }
//                self.categories = CategoryStorage.shared.category
//                
//                DispatchQueue.main.async {
//                   // self.delegate?.updateCollectionView()
//                }
//            })
//    }
//    
//    private func setCornerRadius(cell: CategoryCollectionViewCell, numberRow: Int) {
//        cell.layer.masksToBounds = true
//       
//        switch CategoryStorage.shared.category.count {
//        case 1:
//            cell.layer.cornerRadius = Constants.cornerRadius
//            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//            cell.hideLineView()
//        default:
//            if numberRow == 0 {
//                cell.layer.cornerRadius = Constants.cornerRadius
//                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//            }
//            
//            if numberRow == CategoryStorage.shared.category.count - 1 {
//                cell.layer.cornerRadius = Constants.cornerRadius
//                cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//                cell.hideLineView()
//            }
//        }
//    }
//}
//
//extension CategoryCollectionViewHelper {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifire,
//            for: indexPath
//        ) as? CategoryCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//    
//        guard
//            let category = categories[safe: indexPath.row],
//            let string = category else { return UICollectionViewCell() }
//
//       
//        setCornerRadius(cell: cell, numberRow: indexPath.row)
//        return cell
//    }
//
//}
//
