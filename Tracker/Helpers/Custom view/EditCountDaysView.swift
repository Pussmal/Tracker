import UIKit

final class EditCountDaysView: UIStackView {
    
    private struct ViewConstant {
        static let minusButtonImageName = "buttonMinus"
        static let plusButtonImageName = "buttonPlus"
        static let countButtonSide: CGFloat = 34
    }
    
    private lazy var minusButton: CountButton = {
        let button = CountButton(
            frame: .zero,
            imageName: ViewConstant.minusButtonImageName
        )
        button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusButton: CountButton = {
        let button = CountButton(
            frame: .zero,
            imageName: ViewConstant.plusButtonImageName
        )
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.ypBoldSize32
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubview()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(coundDay: Int, isCheked: Bool) {
        
        //TODO: включить или выключить кнопки плюса или минуса
        
        countLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("CountDay", comment: "count check days"),
            coundDay
        )
    }
    
    private func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        axis = .horizontal
        spacing = 24
    }
    
    private func addSubview() {
        [minusButton, countLabel, plusButton].forEach { addArrangedSubview($0) }
        [minusButton, plusButton].forEach({
            $0.widthAnchor.constraint(equalToConstant: ViewConstant.countButtonSide).isActive = true
            $0.heightAnchor.constraint(equalToConstant: ViewConstant.countButtonSide).isActive = true
        })
    }
    
    @objc
    private func minusButtonTapped() {}
    
    @objc
    private func plusButtonTapped() {}
}

