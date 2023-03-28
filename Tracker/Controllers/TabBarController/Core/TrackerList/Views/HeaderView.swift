import UIKit

protocol HeaderViewDelegate: AnyObject {
    func addTrackerButton()
}

final class HeaderView: UIView {
    
    weak var delegate: HeaderViewDelegate?
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        let imageButton = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(imageButton, for: .normal)
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypBoldSize34
        label.text = "Трекеры"
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale? = Locale(identifier: "Russian")
        picker.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Поиск"
        return searchTextField
    }()
    
    init(frame: CGRect, delegate: HeaderViewDelegate?) {
        super.init(frame: frame)
        self.delegate = delegate
        searchTextField.delegate = self
        setupView()
        addViews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addViews() {
        addSubViews(addTrackerButton, titleLabel, datePicker, searchTextField)
    }
    
    private func activateConstraints() {
        
        let leftConstants = frame.width / 20.8
        let side: CGFloat = frame.width / 20
        let topAnchorConstant = frame.height / 3.20
        
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height + 10),
            widthAnchor.constraint(equalToConstant: frame.width),
            
            addTrackerButton.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorConstant),
            addTrackerButton.leftAnchor.constraint(equalTo: leftAnchor, constant: leftConstants),
            addTrackerButton.widthAnchor.constraint(equalToConstant: side),
            addTrackerButton.heightAnchor.constraint(equalToConstant: side),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: frame.height / 2),
            titleLabel.widthAnchor.constraint(equalToConstant: frame.width / 1.7),
         //   titleLabel.heightAnchor.constraint(equalToConstant: frame.height / 4.4),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.indentationFromEdges),
            
            datePicker.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            datePicker.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.indentationFromEdges),
            datePicker.leftAnchor.constraint(equalTo: titleLabel.rightAnchor),
            
            searchTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchTextField.rightAnchor.constraint(equalTo: datePicker.rightAnchor),
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: frame.height / 18),
            searchTextField.heightAnchor.constraint(equalToConstant: frame.height / 5)
        ])
        
    }
    
    @objc
    private func addTrackerButtonTapped() {
        delegate?.addTrackerButton()
    }
    
    @objc
    private func valueChanged(_ sender: UIDatePicker) {
//        nameTextField.endEditing(true)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH.mm"
//        let dataValue = formatter.string(from: sender.date)
//        let attribute =  [NSAttributedString.Key.foregroundColor: ColorStyle.purple.colorSetings,
//                          NSAttributedString.Key.font: TextFontStyle.body.textFont]
//        let atrrString = NSAttributedString(string: dataValue, attributes: attribute)
//
//        dateLabel.text =  "Каждый день в " + dataValue
//
//        let baseStr = NSMutableAttributedString(string: "Каждый день в ",
//                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
//        baseStr.append(atrrString)
//        dateLabel.attributedText = baseStr
//
    }
}

extension HeaderView: UITextFieldDelegate {}
