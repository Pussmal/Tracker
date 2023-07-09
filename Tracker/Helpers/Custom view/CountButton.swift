import UIKit

final class CountButton: UIButton {

    init(frame: CGRect, imageName: String) {
        super.init(frame: frame)
        setupView(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(imageName: String) {
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .ypColorSelection2
        let image = UIImage(named: imageName)
        setImage(image, for: .normal)
    }
}
