import UIKit

enum ColorPageType: CaseIterable {
    
    private struct ColorPageTypeConstants {
        static let blueOnbordingimageName = "BlueOnboardingBackground"
        static let redOnbordingimageName = "RedOnboardingBackground"
        static let blueInfoText = NSLocalizedString("First label onboarding text", comment: "text for first onboarding label")
        static let redInfoText = NSLocalizedString("Second label onboarding text", comment: "text for second onboarding label")
    }
    
    case blue
    case red
 
    var viewController: UIViewController {
        switch self {
        case .blue:
            return OnboardingViewController(colorPage: self.colorPage)
        case .red:
            return OnboardingViewController(colorPage: self.colorPage)
        }
    }

    private var colorPage: ColorPage {
        ColorPage(backgroundImageName: self.imageName, onboardingInfoText: self.infoText)
    }
    
    private var imageName: String {
        switch self {
        case .blue:
            return ColorPageTypeConstants.blueOnbordingimageName
        case .red:
            return ColorPageTypeConstants.redOnbordingimageName
        }
    }
    
    private var infoText: String {
        switch self {
        case .blue:
            return ColorPageTypeConstants.blueInfoText
        case .red:
            return ColorPageTypeConstants.redInfoText
        }
    }
}
