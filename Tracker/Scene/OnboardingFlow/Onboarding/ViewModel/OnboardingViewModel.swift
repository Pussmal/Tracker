import Foundation

protocol OnboardingViewModelProtocol {
    var updateColorPage: ((ColorPage)-> Void)? { get set }
    func setColorOnboarding()
}

final class OnboardingViewModel: OnboardingViewModelProtocol {
    // MARK: Public properties
    public var updateColorPage: ((ColorPage)-> Void)?
    
    // MARK: private properties
    private let colorPage: ColorPage
    
    // MARK: initialization
    init(colorPage: ColorPage) {
        self.colorPage = colorPage
    }
    
    // MARK: Public methods
    public func setColorOnboarding() {
        updateColorPage?(colorPage)
    }
}
