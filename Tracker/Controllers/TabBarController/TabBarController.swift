import UIKit

final class TabBarController: UITabBarController {
    
    private enum TabBarItem {
        case tracker
        case statistic
        
        var title: String {
            switch self {
            case .tracker:
                return NSLocalizedString("TabBarItemTracker", comment: "Tracker item title")
            case .statistic:
                return NSLocalizedString("TabBarItemStatistics", comment: "Statistic item title")
            }
        }
        
        var image: UIImage? {
            switch self {
            case .tracker:
                return UIImage(named: "record.circle")
            case .statistic:
                return UIImage(named: "hare")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        let tabBarItems: [TabBarItem] = [.tracker, .statistic]
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        let dataProvider = DataProvider()
        
        viewControllers = tabBarItems.compactMap({ item in
            switch item {
            case .tracker:
                let viewController = TrackersViewController(dataProvider: dataProvider)
                return creatNavigationController(vc: viewController, title: item.title)
            case .statistic:
                let statisticProvider = StatisticProvider(dataProvider: dataProvider)
                let viewController = StatisticViewController(statisticProvider: statisticProvider)
                return creatNavigationController(vc: viewController, title: item.title)
            }
        })
        
        viewControllers?.enumerated().forEach({ (index, vc) in
            vc.tabBarItem.title = tabBarItems[index].title
            vc.tabBarItem.image = tabBarItems[index].image
        })
    }
    
    private func creatNavigationController(vc: UIViewController, title: String) -> UINavigationController {
        vc.title = title
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationItem.largeTitleDisplayMode = .always
        navVC.navigationBar.prefersLargeTitles = true
        return navVC
    }
}
    
