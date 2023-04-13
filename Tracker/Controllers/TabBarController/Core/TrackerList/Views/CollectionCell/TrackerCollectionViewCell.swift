import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func checkTracker()
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var checkTracker = false
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var nameAndEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypColorSelection2
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private lazy var daysPlusTrackerButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameTrackerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.ypMediumSize12
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.ypMediumSize12
        return label
    }()
    
    private lazy var checkTrackerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = getButtonImage(checkTracker)
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(checkTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(tracker: Tracker) {
        emojiLabel.text = tracker.emoji
        nameTrackerLabel.text = tracker.name
        
        daysLabel.text = "5 дней"
        
        nameAndEmojiView.backgroundColor = tracker.color
        checkTrackerButton.backgroundColor = getBackgroundButtonColor(color: tracker.color)
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        contentView.addSubViews(stackView)
        stackView.addArrangedSubview(nameAndEmojiView)
        stackView.addArrangedSubview(daysPlusTrackerButtonView)
        
        nameAndEmojiView.addSubViews(emojiLabel,nameTrackerLabel)
        daysPlusTrackerButtonView.addSubViews(daysLabel, checkTrackerButton)
    }
    
    private func activateConstraints() {
        
        let emojiLabelSide: CGFloat = 30
        let checkTrackerButtonSide: CGFloat = 34
        let offset: CGFloat = 12
        
        emojiLabel.layer.cornerRadius = emojiLabelSide / 2
        checkTrackerButton.layer.cornerRadius = checkTrackerButtonSide / 2
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: offset),
            emojiLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: offset),
            emojiLabel.heightAnchor.constraint(equalToConstant: emojiLabelSide),
            emojiLabel.widthAnchor.constraint(equalToConstant: emojiLabelSide),
            
            nameTrackerLabel.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -offset),
            nameTrackerLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: offset),
            nameTrackerLabel.rightAnchor.constraint(equalTo: nameAndEmojiView.rightAnchor, constant: -offset),
            
            checkTrackerButton.widthAnchor.constraint(equalToConstant: checkTrackerButtonSide),
            checkTrackerButton.heightAnchor.constraint(equalToConstant: checkTrackerButtonSide),
            checkTrackerButton.rightAnchor.constraint(equalTo: daysPlusTrackerButtonView.rightAnchor, constant: -offset),
            checkTrackerButton.topAnchor.constraint(equalTo: daysPlusTrackerButtonView.topAnchor, constant: 9),
            checkTrackerButton.bottomAnchor.constraint(equalTo: daysPlusTrackerButtonView.bottomAnchor),
            
            daysLabel.leftAnchor.constraint(equalTo: daysPlusTrackerButtonView.leftAnchor, constant: offset),
            daysLabel.rightAnchor.constraint(equalTo: checkTrackerButton.leftAnchor),
            daysLabel.centerYAnchor.constraint(equalTo: checkTrackerButton.centerYAnchor)
        ])
    }
    
    private func getButtonImage(_ check: Bool) -> UIImage? {
        check ? UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate) : UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
    }
    
    private func getBackgroundButtonColor(color: UIColor?) -> UIColor? {
        checkTracker ? color?.withAlphaComponent(0.3) : color?.withAlphaComponent(1)
    }
    
    @objc
    private func checkTrackerButtonTapped() {
        checkTracker = !checkTracker
        let image = getButtonImage(checkTracker)
        checkTrackerButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: checkTrackerButton.backgroundColor)
        checkTrackerButton.backgroundColor = backgroundColor
        delegate?.checkTracker()
    }
}

