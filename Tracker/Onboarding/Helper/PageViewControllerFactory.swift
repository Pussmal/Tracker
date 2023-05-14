import Foundation

enum ColorPageViewController {
    case blue
    case red
}

final class PageViewControllerFactory {
    private struct factoryConstants {
        static let blueBackgroundImageName = "BlueOnboardingBackground"
        static let blueOnboardingInfoText = "Отслеживайте только то, что хотите"
        static let redBackgroundImageName = "RedOnboardingBackground"
        static let redOnboardingInfoText = "Даже если это не литры воды и йога"
    }
    
    func creatPageViewController(colorPage: ColorPageViewController) -> OnboardingViewController {
        switch colorPage {
        case .blue:
            return OnboardingViewController(
                backgroundImageName: factoryConstants.blueBackgroundImageName,
                onboardingInfoText: factoryConstants.blueOnboardingInfoText)
        case .red:
            return OnboardingViewController(
                backgroundImageName: factoryConstants.redBackgroundImageName,
                onboardingInfoText: factoryConstants.redOnboardingInfoText)
        }
    }
}
