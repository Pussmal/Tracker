import UIKit

final class EditCountDaysView: UIStackView {
    
    private struct ViewConstant {
        static let minusButtonImageName = "buttonMinus"
        static let plusButtonImageName = "buttonPlus"
        static let countButtonSide: CGFloat = 34
    }
    
    private var countDay: Int = 0 {
        didSet {
            if countDay < 0 { countDay = 0 }
        }
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
    
    func config(coundDay: Int, isChecked: Bool, canCheck: Bool) {
        self.countDay =  coundDay
        setCountLabelText(with: self.countDay)
        
        guard !canCheck else {
            minusButton.isEnabled = false
            plusButton.isEnabled = false
            return
        }
        
        if isChecked {
            minusButton.isEnabled = true
            plusButton.isEnabled = false
        } else {
            minusButton.isEnabled = false
            plusButton.isEnabled = true
        }
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
    
    private func setCountLabelText(with count: Int) {
        countLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("CountDay", comment: "count check days"),
            count
        )
    }
    
    @objc
    private func minusButtonTapped() {
        minusButton.showAnimation { [weak self] in
            guard let self else { return }
            self.countDay -= 1
            self.setCountLabelText(with: self.countDay)
            self.minusButton.isEnabled = false
            self.plusButton.isEnabled = true
            print("work minus")
        }
    }
    
    @objc
    private func plusButtonTapped() {
        plusButton.showAnimation { [weak self] in
            guard let self else { return }
            self.countDay += 1
            self.setCountLabelText(with: self.countDay)
            self.minusButton.isEnabled = true
            self.plusButton.isEnabled = false
            print("work plus")
        }
    }
}

