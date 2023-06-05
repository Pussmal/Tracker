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
            return NSLocalizedString("Perfect days", comment: "title for Perfect days statistic label")
        case .completedTrackers:
            return NSLocalizedString("Completed trackers", comment: "title for completed trackers statistic label")
        case .averageValue:
            return NSLocalizedString("Average Value", comment: "title for average value statistic label")
        }
    }
}

final class StatisticView: UIView {
    
    let statisticType: StatisticType
    
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
    
    init(frame: CGRect, statisticType: StatisticType ) {
        self.statisticType = statisticType
        super.init(frame: frame)
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(countForStatistic: Int) {
        switch statisticType {
        case .averageValue:
            statisticCountLabel.text = "\(String(countForStatistic)) %"
        default:
            statisticCountLabel.text = String(countForStatistic)
        }
    }
    
    private func setupView() {
        backgroundColor = .clear
        statisticNameLabel.text = statisticType.titleStatistic
        setGradient()
    }
    
    private func addSubviews() {
        addSubViews(stackView)
        stackView.addArrangedSubview(statisticCountLabel)
        stackView.addArrangedSubview(statisticNameLabel)
    }
    
    private func activateConstraints() {
        let constant: CGFloat = 12
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant),
        ])
    }
    
    private func setGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.locations = [0, 0.5, 1]
        gradient.colors = [
            UIColor.ypredGradient?.cgColor ?? UIColor().cgColor,
            UIColor.ypgreenGradient?.cgColor ?? UIColor().cgColor,
            UIColor.ypblueGradient?.cgColor ?? UIColor().cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: Constants.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        layer.addSublayer(gradient)
    }
}
