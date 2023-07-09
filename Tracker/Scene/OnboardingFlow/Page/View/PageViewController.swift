import UIKit

final class PageViewController: UIPageViewController {
    
    // MARK: - private properties
    private var pagesProvider: PageViewControllerProviderProtocol?
    
    // MARK: - UI
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pagesProvider?.numberOfPages ?? 0
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.isEnabled = false
        return pageControl
    }()
    
    // MARK: - initialization
    init(pagesFactory: PageViewControllerProviderProtocol) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        self.pagesProvider = pagesFactory
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
        guard let firstViewController = pagesProvider?.getViewController(at: 0) else { return }
        
        setViewControllers(
            [firstViewController],
            direction: .forward,
            animated: true
        )
    }
    
    private func addViews() {
        view.addSubview(pageControl)
    }
    
    private func activateConstraints() {
        let pageControlTopConstant = view.frame.height / 1.45
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: pageControlTopConstant
            ),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pagesProvider?.getViewControllerIndex(of: viewController) else { return nil }
        let prevIndex = viewControllerIndex - 1
        guard prevIndex >= 0 else { return nil }
        return pagesProvider?.getViewController(at: prevIndex)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let viewControllerIndex = pagesProvider?.getViewControllerIndex(of: viewController),
            let pagesProvider else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pagesProvider.numberOfPages else { return nil }
        return pagesProvider.getViewController(at: nextIndex)
    }
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pagesProvider?.getViewControllerIndex(of: currentViewController) else { return }
        pageControl.currentPage = currentIndex
    }
}
