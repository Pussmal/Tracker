import UIKit

final class SheduleCategoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifire = "SheduleCategoryCollectionViewCell"
    
    private struct SheduleCategoryCollectionViewCell {
        static let chevronImageName = "Chevron"
    }
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypRegularSize17
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(
            named: SheduleCategoryCollectionViewCell.chevronImageName
        )?.withRenderingMode(.alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .right
        return imageView
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        return view
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
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypBackground
    }
    
    func config(category: String?) {
        categoryLabel.text = category
    }
    
    func hideLineView() {
        lineView.isHidden = true
    }
    
    private func addSubview() {
        contentView.addSubViews(
            categoryLabel,
            chevronImageView,
            lineView
        )
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.indentationFromEdges),
            categoryLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.indentationFromEdges),
            chevronImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            
            lineView.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: chevronImageView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
