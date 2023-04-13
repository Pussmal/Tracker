import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifire = "ColorCollectionViewCell"
    
    var cellIsSelected = false {
        didSet {
            cellIsSelected ? showBorderCell() : hideBorderCell()
        }
    }

    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
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
        contentView.backgroundColor = .clear
        layer.cornerRadius = 8
    }
    
    func config(color: UIColor?) {
        colorView.backgroundColor = color
    }
        
    private func addSubview() {
        contentView.addSubview(colorView)
    }
    
    private func showBorderCell() {
        layer.borderWidth = 3
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
    }
    
    private func hideBorderCell() {
        layer.borderWidth = 0
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
    }
    
    private func activateConstraints() {
        
        let edge: CGFloat = 5
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edge),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -edge),
        ])
    }
}
