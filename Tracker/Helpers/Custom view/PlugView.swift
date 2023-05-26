import UIKit

enum PlugViewType {
    case trackers
    case search
    case category
    
    var text: String {
        switch self {
        case .trackers: return NSLocalizedString("Trackers plug", comment: "Text for trackers plugView")
        case .search: return NSLocalizedString("Search plug" , comment: "Text for search plugView")
        case .category: return NSLocalizedString("Category plug", comment: "Text for category plugView")
        }
    }
    
    var image: UIImage {
        switch self {
        case .trackers, .category:
            return UIImage(named: "plug") ?? UIImage()
        case .search:
            return UIImage(named: "notFound") ?? UIImage()
        }
    }
}

final class PlugView: UIStackView {
        
    private lazy var plugImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var plugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.ypMediumSize12
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(frame: CGRect, plug: PlugViewType) {
        super.init(frame: frame)
        setupView()
        addSubview()
        plugLabel.text = plug.text
        plugImageView.image = plug.image
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(plug: PlugViewType) {
        plugLabel.text = plug.text
        plugImageView.image = plug.image
    }
    
    private func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        axis = .vertical
        spacing = 8
    }
    
    private func addSubview() {
        addArrangedSubview(plugImageView)
        addArrangedSubview(plugLabel)
    }
}

