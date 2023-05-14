import UIKit

final class PageViewController: UIPageViewController {
    
    // MARK: - private properties
    private let pagesFactory = PageViewControllerFactory()
    
    private lazy var pages: [UIViewController] = { [
        pagesFactory.creatPageViewController(colorPage: .blue),
        pagesFactory.creatPageViewController(colorPage: .red)
    ]
    }()
    
    // MARK: - UI
    private lazy var pageControll: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.translatesAutoresizingMaskIntoConstraints = false
        pageControll.numberOfPages = pages.count
        pageControll.currentPage = 0
        pageControll.currentPageIndicatorTintColor = .ypBlack
        pageControll.pageIndicatorTintColor = .ypGray
        pageControll.isEnabled = false
        return pageControll
    }()
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        addViews()
        activateConstraints()
    }
    
    // MARK: - private methods
    private func setupPageViewController() {
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
    
    private func addViews() {
        view.addSubview(pageControll)
    }
    
    private func activateConstraints() {
        let pageControllTopConstant = view.frame.height / 1.45
        
        NSLayoutConstraint.activate([
            pageControll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: pageControllTopConstant),
            pageControll.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else { return }
        pageControll.currentPage = currentIndex
    }
}
