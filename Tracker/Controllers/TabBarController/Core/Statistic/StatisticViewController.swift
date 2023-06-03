import UIKit

final class StatisticViewController: UIViewController {
    
    //MARK: - private properties
    private let statisticProvider: StatisticProviderProtocol
    
    // MARK: UI
    private lazy var plugView: PlugView = {
        let plugView = PlugView(frame: .zero, plug: .statistic)
        return plugView
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
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        view.addSubViews(plugView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
