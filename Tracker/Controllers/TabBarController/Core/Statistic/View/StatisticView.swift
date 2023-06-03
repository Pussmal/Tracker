import UIKit

enum StatisticType: CaseIterable {
    case bestPeriod
    case perfectDays
    case completedTrackers
    case averageValue
    
    var titleStatistic: String {
        switch self {
        case .bestPeriod:
            return NSLocalizedString("Best period", comment: "title for Best period statistic label")
        case .perfectDays:
            return NSLocalizedString("Perfect period", comment: "title for Perfect period statistic label")
        case .completedTrackers:
            return NSLocalizedString("Completed trackers", comment: "title for completed trackers statistic label")
        case .averageValue:
            return NSLocalizedString("Average Value", comment: "title for average value statistic label")
        }
    }
}

final class StatisticView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var statisticNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.ypMediumSize12
        label.textAlignment = .left
        return label
    }()
    
    private lazy var statisticCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.ypBoldSize34
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(type: StatisticType, countForStatistic: Int) {
        statisticNameLabel.text = type.titleStatistic
        statisticCountLabel.text = String(countForStatistic)
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = Constants.cornerRadius
    }
    
    private func addSubviews() {
        addSubViews(stackView)
        stackView.addArrangedSubview(statisticCountLabel)
        stackView.addArrangedSubview(statisticNameLabel)
    }
    
    private func activateConstraints() {
        let constant: CGFloat = 5
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant),
        ])
    }
}
