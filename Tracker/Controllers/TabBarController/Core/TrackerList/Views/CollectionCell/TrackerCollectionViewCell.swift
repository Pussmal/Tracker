import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func checkTracker(id: String?, completed: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    var interaction: UIContextMenuInteraction? {
        didSet {
            if let interaction { nameAndEmojiView.addInteraction(interaction) }
        }
    }
    
    private struct TrackerCollectionViewCellConstants {
        static let emojiLabelSide: CGFloat = 30
        static let checkTrackerButtonSide: CGFloat = 34
        static let offset: CGFloat = 12
    }
    
    private var completedTracker = false {
        didSet {
            if completedTracker {
                daysCount += 1
            } else {
                daysCount -= 1
            }
        }
    }
    
    private var idTracker: String?
    private var daysCount: Int = 0
    
    // MARK: UI
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var nameAndEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private lazy var daysPlusTrackerButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
        let image = getButtonImage(completedTracker)
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(checkTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public methods
    func config(tracker: Tracker, completedDaysCount: Int?, completed: Bool) {
        emojiLabel.text = tracker.emoji
        nameTrackerLabel.text = tracker.name
        nameAndEmojiView.backgroundColor = tracker.color
        checkTrackerButton.backgroundColor = getBackgroundButtonColor(color: tracker.color)
        idTracker = tracker.id
        completedTracker = completed
        
        let image = getButtonImage(completedTracker)
        checkTrackerButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: checkTrackerButton.backgroundColor)
        checkTrackerButton.backgroundColor = backgroundColor
        
        guard let completedDaysCount else { return }
        daysCount = completedDaysCount
        setDaysLabel()
    }
    
    func enabledCheckTrackerButton(enabled: Bool) {
        checkTrackerButton.isEnabled = !enabled
    }
    
    // MARK: Private methods
    private func setupCell() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        contentView.addSubViews(stackView)
        stackView.addArrangedSubview(nameAndEmojiView)
        stackView.addArrangedSubview(daysPlusTrackerButtonView)
        
        nameAndEmojiView.addSubViews(emojiLabel,nameTrackerLabel)
        daysPlusTrackerButtonView.addSubViews(daysLabel, checkTrackerButton)
    }
    
    private func activateConstraints() {
        emojiLabel.layer.cornerRadius = TrackerCollectionViewCellConstants.emojiLabelSide / 2
        checkTrackerButton.layer.cornerRadius = TrackerCollectionViewCellConstants.checkTrackerButtonSide / 2
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: TrackerCollectionViewCellConstants.offset),
            emojiLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: TrackerCollectionViewCellConstants.offset),
            emojiLabel.heightAnchor.constraint(equalToConstant: TrackerCollectionViewCellConstants.emojiLabelSide),
            emojiLabel.widthAnchor.constraint(equalToConstant: TrackerCollectionViewCellConstants.emojiLabelSide),
            
            nameTrackerLabel.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -TrackerCollectionViewCellConstants.offset),
            nameTrackerLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: TrackerCollectionViewCellConstants.offset),
            nameTrackerLabel.rightAnchor.constraint(equalTo: nameAndEmojiView.rightAnchor, constant: -TrackerCollectionViewCellConstants.offset),
            
            checkTrackerButton.widthAnchor.constraint(equalToConstant: TrackerCollectionViewCellConstants.checkTrackerButtonSide),
            checkTrackerButton.heightAnchor.constraint(equalToConstant: TrackerCollectionViewCellConstants.checkTrackerButtonSide),
            checkTrackerButton.rightAnchor.constraint(equalTo: daysPlusTrackerButtonView.rightAnchor, constant: -TrackerCollectionViewCellConstants.offset),
            checkTrackerButton.topAnchor.constraint(equalTo: daysPlusTrackerButtonView.topAnchor, constant: 9),
            checkTrackerButton.bottomAnchor.constraint(equalTo: daysPlusTrackerButtonView.bottomAnchor),
            
            daysLabel.leftAnchor.constraint(equalTo: daysPlusTrackerButtonView.leftAnchor, constant: TrackerCollectionViewCellConstants.offset),
            daysLabel.rightAnchor.constraint(equalTo: checkTrackerButton.leftAnchor),
            daysLabel.centerYAnchor.constraint(equalTo: checkTrackerButton.centerYAnchor)
        ])
    }
    
    private func getButtonImage(_ check: Bool) -> UIImage? {
        let doneImage = UIImage(named: "Done")
        let plusImage = UIImage(systemName: "plus")
        return check ? doneImage : plusImage
    }
    
    private func getBackgroundButtonColor(color: UIColor?) -> UIColor? {
        completedTracker ? color?.withAlphaComponent(0.3) : color?.withAlphaComponent(1)
    }
    
    @objc
    private func checkTrackerButtonTapped() {
        completedTracker = !completedTracker
        let image = getButtonImage(completedTracker)
        checkTrackerButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: checkTrackerButton.backgroundColor)
        checkTrackerButton.backgroundColor = backgroundColor
        setDaysLabel()
        delegate?.checkTracker(id: self.idTracker, completed: completedTracker)
    }
    
    private func setDaysLabel() {
        daysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("CountDay", comment: "count check days"),
            daysCount
        )
    }
}



