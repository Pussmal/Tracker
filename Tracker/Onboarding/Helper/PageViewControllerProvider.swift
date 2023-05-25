import UIKit

protocol PageViewControllerProviderProtocol {
    var numberOfPages: Int { get }
    func getViewControllerIndex(of: UIViewController) -> Int?
    func getViewController(at index: Int) -> UIViewController?
}

final class PageViewControllerProvider {
    private var viewControllers: [UIViewController] = ColorPageType.allCases.compactMap { $0.viewController }
}

extension PageViewControllerProvider: PageViewControllerProviderProtocol {
    var numberOfPages: Int { return ColorPageType.allCases.count }

    func getViewController(at index: Int) -> UIViewController? {
        viewControllers[safe: index]
    }
    
    func getViewControllerIndex(of viewController: UIViewController) -> Int? {
        viewControllers.firstIndex(of: viewController)
    }
}
