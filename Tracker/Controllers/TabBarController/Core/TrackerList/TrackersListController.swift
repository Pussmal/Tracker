import UIKit

final class TrackersListController: UIViewController {
   
    private var headerView: HeaderView!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.isHidden = true
        
        headerView = HeaderView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: view.bounds.width, height: view.bounds.height / 4.45)),
            delegate: self)
        
        print(view.frame)
        
        view.addSubViews(headerView, collectionView)
      
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func creatLeftBarButton() {
        let leftTabBarButtonIcon = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let leftBarButton = UIBarButtonItem(image: leftTabBarButtonIcon, style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
    }
    
    @objc
    private func leftBarButtonTapped() {
        print("leftBarButtonTapped")
    }
    
    @objc
    private func valueChanged(_ sender: UIDatePicker) {
        //        nameTextField.endEditing(true)
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "HH.mm"
        //        let dataValue = formatter.string(from: sender.date)
        //        let attribute =  [NSAttributedString.Key.foregroundColor: ColorStyle.purple.colorSetings,
        //                          NSAttributedString.Key.font: TextFontStyle.body.textFont]
        //        let atrrString = NSAttributedString(string: dataValue, attributes: attribute)
        //
        //        dateLabel.text =  "Каждый день в " + dataValue
        //
        //        let baseStr = NSMutableAttributedString(string: "Каждый день в ",
        //                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        //        baseStr.append(atrrString)
        //        dateLabel.attributedText = baseStr
        //
    }
}



extension TrackersListController: HeaderViewDelegate {
    func addTrackerButton() {
        showTypeTrackerViewController()
    }
}

extension TrackersListController: UICollectionViewDelegate {}

extension TrackersListController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 48) / 2
        return CGSize(width: width, height: view.frame.height / 6.15)
    }
}

extension TrackersListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.identifier,
                for: indexPath
            ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = Tracker(id: "", name: "Бабушка прислала открытку в ватс ап", color: "", emoji: "😀")
        
        cell.config(tracker: tracker)
        return cell
    }
}

// MARK: TypeTrackerViewController
extension TrackersListController {
    private var typeTrackerViewController: TypeTrackerViewController {
        return TypeTrackerViewController()
    }
    
    private func showTypeTrackerViewController() {
        present(typeTrackerViewController, animated: true)
    }
}
