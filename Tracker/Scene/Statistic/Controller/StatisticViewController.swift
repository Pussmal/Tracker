import UIKit

final class StatisticViewController: UIViewController {
    
    //MARK: - private properties
    private let statisticProvider: StatisticProviderProtocol
    
    // MARK: UI
    private lazy var plugView = PlugView(frame: .zero, plug: .statistic)
    private lazy var statisticViews: [StatisticView] = []
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.spacing = 10
        return stackView
    }()
    
    init(statisticProvider: StatisticProviderProtocol) {
        self.statisticProvider = statisticProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addSubviews()
        activateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plugView.isHidden = statisticProvider.isTrackersInCoreData
        statisticViews.forEach { $0.isHidden = !statisticProvider.isTrackersInCoreData }
        statisticViews.forEach {
            var textForStatistic: String
            switch $0.statisticType {
            case .bestPeriod:
                textForStatistic = String(statisticProvider.bestPeriod)
            case .perfectDays:
                textForStatistic = String(statisticProvider.perfectDays)
            case .completedTrackers:
                textForStatistic = String(statisticProvider.completedTrackers)
            case .averageValue:
                textForStatistic = String(format: "%.01f", statisticProvider.averageValue)
            }
            $0.config(countForStatistic: textForStatistic)
        }
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        view.addSubViews(plugView, stackView)
        let statisticViewWidth = UIScreen.main.bounds.width - (Constants.indentationFromEdges * 2)
        let statisticViewSize = CGSize(
            width: statisticViewWidth,
            height: Constants.statisticLabelHeight
        )
        statisticViews = StatisticType.allCases.enumerated().compactMap({ (index, type)  in
            return StatisticView(
                frame: CGRect(origin: .zero, size: statisticViewSize),
                statisticType: type
            )
        })
        statisticViews.forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges)
        ])
        
        statisticViews.forEach {
            $0.heightAnchor.constraint(equalToConstant: Constants.statisticLabelHeight).isActive = true
        }
    }
}
