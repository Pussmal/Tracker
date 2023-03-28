import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .green
        return stackView
    }()
    
    private lazy var nameAndEmojiStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .ypColorSelection2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var daysPlusTrackerButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .green
        return stackView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
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
    
    private var checkTrackerButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
        nameLabel.text = tracker.name
        
        daysLabel.text = "5 дней"
        
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        contentView.addSubViews(stackView)
        stackView.addArrangedSubview(nameAndEmojiStackView)
        stackView.addArrangedSubview(daysPlusTrackerButtonStackView)
        
        nameAndEmojiStackView.addArrangedSubview(emojiLabel)
        nameAndEmojiStackView.addArrangedSubview(nameLabel)
        
        daysPlusTrackerButtonStackView.addArrangedSubview(daysLabel)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
//            nameAndEmojiStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            nameAndEmojiStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            nameAndEmojiStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
//
//            daysPlusTrackerButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            daysPlusTrackerButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            daysPlusTrackerButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
            //            emojiLabel.centerYAnchor.constraint(equalTo: nameAndEmojiStackView.centerYAnchor),
            //            emojiLabel.centerXAnchor.constraint(equalTo: nameAndEmojiStackView.centerXAnchor),
            //
            //            emojiLabel.centerYAnchor.constraint(equalTo: nameAndEmojiStackView.centerYAnchor),
            //            emojiLabel.centerXAnchor.constraint(equalTo: nameAndEmojiStackView.centerXAnchor),
        ])
    }
}

