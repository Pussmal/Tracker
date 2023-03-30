import UIKit

protocol CreateTrackerViewDelegate: AnyObject {
    func createTracker()
    func cancelCreate()
}

final class CreateTrackerView: UIView {

    // MARK: -Delegate
    weak var delegate: CreateTrackerViewDelegate?

    // MARK: -CreateTrackerViewConstants
    private struct CreateTrackerViewConstants {
        static let cancelButtonTitle = "Отменить"
        static let createButtonTitle = "Создать"
        static let textFieldPlaceholder = "Введите название трекера"

        static let standartCellIdentifire = "cell"

        static let spacingConstant: CGFloat = 8
    }

    // MARK: -Private properties
    private var typeTracer: TypeTracker
    private var contentSize: CGSize {
        CGSize(width: frame.width, height: 931)
    }

    private var emojiCollectionViewHelper: EmojiCollectionViewHelper
    private var colorsCollectionViewHelper: ColorsCollectionViewHelper
    private var sheduleCategoryTableViewHelper: SheduleCategoryTableViewHelper

    // MARK: UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentSize = contentSize
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame.size = contentSize
        return contentView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        return stackView
    }()

    private lazy var collectionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        return stackView
    }()

    private lazy var nameTrackerTextField: NameTrackerTextField = {
        let textField = NameTrackerTextField(
            frame: .zero,
            placeholderText: CreateTrackerViewConstants.textFieldPlaceholder
        )
        return textField
    }()

    private lazy var sheduleCategoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: CreateTrackerViewConstants.standartCellIdentifire
        )
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = Constants.cornerRadius
        return tableView
    }()

    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "colorCell"
        )
        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifire
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifire)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "emojiCell"
        )
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifire
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifire)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = CreateTrackerViewConstants.spacingConstant
        return stackView
    }()

    private lazy var cancelButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CreateTrackerViewConstants.cancelButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.borderColor = UIColor.ypRed?.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var createButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CreateTrackerViewConstants.createButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    // MARK: -Initialization
    init(
        frame: CGRect,
        delegate: CreateTrackerViewDelegate?,
        typeTracker: TypeTracker
    ) {
        self.delegate = delegate
        self.typeTracer = typeTracker
        emojiCollectionViewHelper = EmojiCollectionViewHelper()
        colorsCollectionViewHelper = ColorsCollectionViewHelper()
        sheduleCategoryTableViewHelper = SheduleCategoryTableViewHelper(typeTracker: typeTracker)
        super.init(frame: frame)

        colorCollectionView.dataSource = colorsCollectionViewHelper
        colorCollectionView.delegate = colorsCollectionViewHelper

        emojiCollectionView.dataSource = emojiCollectionViewHelper
        emojiCollectionView.delegate = emojiCollectionViewHelper

        sheduleCategoryTableView.dataSource = sheduleCategoryTableViewHelper
        sheduleCategoryTableView.delegate = sheduleCategoryTableViewHelper

        setupView()
        addViews()
        activateConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }

    private func addViews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubViews(
            nameTrackerTextField,
            stackView,
            buttonStackView
        )
        
        stackView.addArrangedSubview(sheduleCategoryTableView)
        stackView.addArrangedSubview(collectionStackView)

        collectionStackView.addArrangedSubview(emojiCollectionView)
        collectionStackView.addArrangedSubview(colorCollectionView)

        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }

    private func activateConstraints() {

        var tableViewHeight: CGFloat = Constants.hugHeight

        switch typeTracer {
        case .Habit:
            tableViewHeight *= 2
        case .Event:
            break
        }

        let buttonHeight: CGFloat = 60
        let verticalAxis: CGFloat = 10
        let edge = Constants.indentationFromEdges

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalAxis),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: Constants.hugHeight),

            stackView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            stackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10),

            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight),

            sheduleCategoryTableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
        ])
    }

    @objc
    private func createButtonTapped() {
        createButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.createTracker()
        }
    }

    @objc
    private func cancelButtonTapped() {
        cancelButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.cancelCreate()
            print(self.collectionStackView.frame)
        }
    }
}
