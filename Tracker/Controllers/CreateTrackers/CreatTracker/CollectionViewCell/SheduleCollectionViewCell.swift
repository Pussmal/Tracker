import UIKit

protocol SheduleCollectionViewCellProtocol: AnyObject {
    func getSelectedDay(_ indexPath: IndexPath?, select: Bool)
}

final class SheduleCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifire = "SheduleCollectionViewCell"
    
    weak var delegate: SheduleCollectionViewCellProtocol?
    var indexPath: IndexPath?
        
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypRegularSize17
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: #selector(switchChange(_:)), for: .valueChanged)
        return switchView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubview()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(day: String?) {
        dayLabel.text = day
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypBackground
    }
        
    private func addSubview() {
        contentView.addSubViews(
            dayLabel,
            switchView
        )
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.indentationFromEdges),
            dayLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.indentationFromEdges),
        ])
    }
    
    @objc
    private func switchChange(_ sender: UISwitch) {
        delegate?.getSelectedDay(indexPath, select: sender.isOn)
    }
}
