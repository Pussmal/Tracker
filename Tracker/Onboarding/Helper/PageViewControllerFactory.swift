import UIKit

protocol PageViewControllerFactoryProtocol {
    var numberOfPages: Int { get }
    var currentNumberPage: Int { get }
    var prevViewController: UIViewController? { get }
    var nextViewController: UIViewController? { get }
    var firstViewController: UIViewController? { get }
}

final class PageViewControllerFactory {
    
    private var prevColorPageTypeIndex = 0
    private var nextColorPageTypeIndex = 0
    
    private var currentColorPageTypeIndex = 0 {
        didSet {
            prevColorPageTypeIndex = currentColorPageTypeIndex - 1
            nextColorPageTypeIndex = currentColorPageTypeIndex + 1
        }
    }
    
    private func createPageViewController(colorPageType: ColorPageType) -> UIViewController {
        let colorPage = ColorPage(
            backgroundImageName: colorPageType.imageName,
            onboardingInfoText: colorPageType.infoText)
        return OnboardingViewController(colorPage: colorPage)
    }
}

extension PageViewControllerFactory: PageViewControllerFactoryProtocol {
    var numberOfPages: Int { return ColorPageType.allCases.count }
    
    var prevViewController: UIViewController? {
        guard prevColorPageTypeIndex >= 0 else { return nil }
        let colorPageType = ColorPageType.allCases[prevColorPageTypeIndex]
        self.currentColorPageTypeIndex -= 1
        return createPageViewController(colorPageType: colorPageType)
    }
    
    var nextViewController: UIViewController? {
        guard nextColorPageTypeIndex < ColorPageType.allCases.count else { return nil }
        let colorPageType = ColorPageType.allCases[nextColorPageTypeIndex]
        self.currentColorPageTypeIndex += 1
        return createPageViewController(colorPageType: colorPageType)
    }
    
    var firstViewController: UIViewController? {
        guard let firstColorPageType = ColorPageType.allCases.first else { return nil }
        return createPageViewController(colorPageType: firstColorPageType)
    }
    
    var currentNumberPage: Int {
        currentColorPageTypeIndex
    }
}
