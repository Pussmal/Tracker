import UIKit

protocol OnboardingViewDelegate: AnyObject {
    func onboardingButtonTapped()
}

final class OnboardingView: UIView {
    
    //MARK: - delegate
    weak var delegate: OnboardingViewDelegate?
   
    private var colorPage: ColorPage? {
        didSet {
            updateView()
        }
    }
    
    //MARK: - viewConstants
    private struct ViewConstants {
        static let okButtonTitle = NSLocalizedString(
            LocalizedKey.onboardingButton.rawValue, comment: "Title for okButton"
        )
    }
    
    // MARK: - UI
    private lazy var backgroundImageView = makeBackgroundImageView()
    private lazy var infoLabel = makeInfoLabel()
    private lazy var okButton = makeOkButton()
    
    // MARK: - initialization
   override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubview()
        activateConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public methods
    public func setColorPage(colorPage: ColorPage) {
        self.colorPage = colorPage
    }
}

// MARK: - private methods
private extension OnboardingView {
    func makeBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }
    
    func makeInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.ypBoldSize32
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    func makeOkButton() -> UIButton {
        let button = TrackerButton(
            frame: .zero,
            title: ViewConstants.okButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(okButtonTapped),
            for: .touchUpInside
        )
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    func updateView() {
        super.layoutSubviews()
        let image = UIImage(named: colorPage?.backgroundImageName ?? "")
        backgroundImageView.image = image
        infoLabel.text = colorPage?.onboardingInfoText
    }
        
    func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addSubview() {
        addSubViews(
            backgroundImageView,
            infoLabel,
            okButton
        )
    }
    
    func activateConstraints() {
        let infoLabelSideConstants: CGFloat = 14
        let infoLabelTopConstants: CGFloat = self.frame.height / 2
        let okButtonConstants: CGFloat = 20
        let okButtonButtonConstants: CGFloat = self.frame.height / 9.5
        let okButtonHeight: CGFloat = 65
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: infoLabelSideConstants),
            infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -infoLabelSideConstants),
            infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: infoLabelTopConstants),
            
            okButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: okButtonConstants),
            okButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -okButtonConstants),
            okButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -okButtonButtonConstants),
            okButton.heightAnchor.constraint(equalToConstant: okButtonHeight)
        ])
    }
    
    @objc
    func okButtonTapped() {
        okButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.onboardingButtonTapped()
        }
    }
}

