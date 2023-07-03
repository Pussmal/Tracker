import UIKit

protocol PageViewControllerProviderProtocol {
    var numberOfPages: Int { get }
    func getViewControllerIndex(of: UIViewController) -> Int?
    func getNewViewController(at index: Int) -> Result<UIViewController?, Never>
    func getViewController(at index: Int) -> UIViewController?
    
}

final class PageViewControllerProvider {
    private var viewControllers: [UIViewController] = ColorPageType.allCases.compactMap {
        let viewModel = OnboardingViewModel(colorPage: $0.colorPage)
        return OnboardingViewController(viewModel: viewModel) }
}

extension PageViewControllerProvider: PageViewControllerProviderProtocol {
    func getNewViewController(at index: Int) -> Result<UIViewController?, Never> {
        return .success(viewControllers[safe: index])
    }
    
    var numberOfPages: Int { ColorPageType.allCases.count }

    func getViewController(at index: Int) -> UIViewController? {
        viewControllers[safe: index]
    }
    
    func getViewControllerIndex(of viewController: UIViewController) -> Int? {
        viewControllers.firstIndex(of: viewController)
    }
}
