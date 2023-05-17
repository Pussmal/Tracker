import UIKit

protocol PageViewControllerFactoryProtocol {
    var numberOfPages: Int { get }
    var currentNumberPage: Int? { get }
    var prevViewController: UIViewController? { get }
    var nextViewController: UIViewController? { get }
    var firstViewController: UIViewController? { get }
}

final class PageViewControllerFactory {
    
    private var prevColorPageTypeIndex: Int?
    private var nextColorPageTypeIndex: Int?
    private var currentColorPageTypeIndex: Int?
    
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
        guard let currentColorPageTypeIndex else { return nil }
        let previousIndex = currentColorPageTypeIndex - 1
        guard previousIndex > 0 else { return nil }
        let colorPageType = ColorPageType.allCases[previousIndex]
        self.currentColorPageTypeIndex = previousIndex
        return createPageViewController(colorPageType: colorPageType)
    }
    
    var nextViewController: UIViewController? {
        guard let currentColorPageTypeIndex else { return nil }
        let nextIndex = currentColorPageTypeIndex + 1
        guard nextIndex < ColorPageType.allCases.count else { return nil }
        let colorPageType = ColorPageType.allCases[nextIndex]
        self.currentColorPageTypeIndex = nextIndex
        return createPageViewController(colorPageType: colorPageType)
    }
    
    var firstViewController: UIViewController? {
        guard let firstColorPageType = ColorPageType.allCases.first else { return nil }
        self.currentColorPageTypeIndex = ColorPageType.allCases.firstIndex(of: firstColorPageType)
        return createPageViewController(colorPageType: firstColorPageType)
    }
    
    var currentNumberPage: Int? {
        currentColorPageTypeIndex
    }
}
