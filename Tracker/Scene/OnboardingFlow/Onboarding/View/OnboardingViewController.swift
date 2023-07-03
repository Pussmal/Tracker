import UIKit

final class OnboardingViewController: UIViewController {
    
    //MARK: - private properties
    private var viewModel: OnboardingViewModelProtocol
    
    //MARK: UI
    private lazy var onboardingView = makeOnboardingView()
    
    // MARK: - initialization
    init(viewModel: OnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addViews()
        activateConstraints()
        bind()
        viewModel.setColorOnboarding()
    }
}

//MARK: - private methods
private extension OnboardingViewController {
    func makeOnboardingView() -> OnboardingView {
        let view = OnboardingView(frame: view.bounds)
        view.delegate = self
        return view
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func addViews() {
        view.addSubview(onboardingView)
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func showMainViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration")}
        let tabBarVC = TabBarController()
        window.rootViewController = tabBarVC
        UserDefaults.standard.set(true, forKey: Constants.firstEnabledUserDefaultsKey)
    }
    
    func bind() {
        viewModel.updateColorPage = { [weak self] colorPage in
            self?.onboardingView.setColorPage(colorPage: colorPage)
        }
    }
}

// MARK: OnboardingViewDelegate
extension OnboardingViewController: OnboardingViewDelegate {
    func onboardingButtonTapped() {
        showMainViewController()
    }
}
