import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifire = "EmojiCollectionViewCell"
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypBoldSize32
        return label
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
        contentView.layer.cornerRadius = 16
    }
    
    func config(emoji: String?) {
        emojiLabel.text = emoji
    }
    
    func showHighlightCell() {
        contentView.backgroundColor = .ypLightGray
    }
    
    func hideHighlightCell() {
        contentView.backgroundColor = .clear
    }
    
    private func addSubview() {
        contentView.addSubview(emojiLabel)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}
