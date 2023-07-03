import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func checkTracker(id: String?, completed: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    static var defaultReuseIdentifier: String { "TrackerCell" }
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    var interaction: UIContextMenuInteraction? {
        didSet {
            if let interaction { nameAndEmojiView.addInteraction(interaction) }
        }
    }
    
    private struct CellConstants {
        static let pinImageNamed = "pin"
        static let doneImageNamed = "Done"
        static let plusImageNamed = "plus"
        static let daysLabellocalizedStringKey = "CountDay"
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
    
    private lazy var pinImageView: UIImageView = {
        let image = UIImage(named: CellConstants.pinImageNamed)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
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
    func config(tracker: Tracker, completedDaysCount: Int?, completed: Bool, isPinned: Bool) {
        emojiLabel.text = tracker.emoji
        nameTrackerLabel.text = tracker.name
        nameAndEmojiView.backgroundColor = tracker.color
        checkTrackerButton.backgroundColor = getBackgroundButtonColor(color: tracker.color)
        idTracker = tracker.id
        completedTracker = completed
        
        pinImageView.isHidden = !isPinned
        
        let image = getButtonImage(completedTracker)
        checkTrackerButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: checkTrackerButton.backgroundColor)
        checkTrackerButton.backgroundColor = backgroundColor
        
        guard let completedDaysCount else { return }
        daysCount = completedDaysCount
        setDaysLabel()
    }
    
    func enabledCheckTrackerButton(enabled: Bool) {
        checkTrackerButton.isEnabled = enabled
    }
    
    // MARK: Private methods
    private func setupCell() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        contentView.addSubViews(stackView)
        stackView.addArrangedSubview(nameAndEmojiView)
        stackView.addArrangedSubview(daysPlusTrackerButtonView)
        
        nameAndEmojiView.addSubViews(emojiLabel,nameTrackerLabel, pinImageView)
        daysPlusTrackerButtonView.addSubViews(daysLabel, checkTrackerButton)
    }
    
    private func activateConstraints() {
        emojiLabel.layer.cornerRadius = CellConstants.emojiLabelSide / 2
        checkTrackerButton.layer.cornerRadius = CellConstants.checkTrackerButtonSide / 2
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: CellConstants.offset),
            emojiLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: CellConstants.offset),
            emojiLabel.heightAnchor.constraint(equalToConstant: CellConstants.emojiLabelSide),
            emojiLabel.widthAnchor.constraint(equalToConstant: CellConstants.emojiLabelSide),
            
            nameTrackerLabel.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -CellConstants.offset),
            nameTrackerLabel.leftAnchor.constraint(equalTo: nameAndEmojiView.leftAnchor, constant: CellConstants.offset),
            nameTrackerLabel.rightAnchor.constraint(equalTo: nameAndEmojiView.rightAnchor, constant: -CellConstants.offset),
            
            checkTrackerButton.widthAnchor.constraint(equalToConstant: CellConstants.checkTrackerButtonSide),
            checkTrackerButton.heightAnchor.constraint(equalToConstant: CellConstants.checkTrackerButtonSide),
            checkTrackerButton.rightAnchor.constraint(equalTo: daysPlusTrackerButtonView.rightAnchor, constant: -CellConstants.offset),
            checkTrackerButton.topAnchor.constraint(equalTo: daysPlusTrackerButtonView.topAnchor, constant: 9),
            checkTrackerButton.bottomAnchor.constraint(equalTo: daysPlusTrackerButtonView.bottomAnchor),
            
            daysLabel.leftAnchor.constraint(equalTo: daysPlusTrackerButtonView.leftAnchor, constant: CellConstants.offset),
            daysLabel.rightAnchor.constraint(equalTo: checkTrackerButton.leftAnchor),
            daysLabel.centerYAnchor.constraint(equalTo: checkTrackerButton.centerYAnchor),
            
            pinImageView.topAnchor.constraint(equalTo: emojiLabel.topAnchor),
            pinImageView.rightAnchor.constraint(equalTo: nameAndEmojiView.rightAnchor, constant: -CellConstants.offset),
        ])
    }
    
    private func getButtonImage(_ check: Bool) -> UIImage? {
        let doneImage = UIImage(named: CellConstants.doneImageNamed)
        let plusImage = UIImage(systemName: CellConstants.plusImageNamed)
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
            NSLocalizedString(CellConstants.daysLabellocalizedStringKey, comment: "count check days"),
            daysCount
        )
    }
}



