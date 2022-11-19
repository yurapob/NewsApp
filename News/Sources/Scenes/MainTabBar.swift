import UIKit

class MainTabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupVCs()
    }
}

private extension MainTabBar {
    
    func setup() {
        view.backgroundColor = Theme.Colors.navigationWhite
        UITabBar.appearance().barTintColor = Theme.Colors.navigationWhite
        tabBar.tintColor = Theme.Colors.black
    }
    
    func setupVCs() {
        
        viewControllers = [
            createNavigationController(for: MainBuilder.build(), title: Localized(.tab_bar_screen_home), image: UIImage(systemName: "house")),
            createNavigationController(for: FavoriteBuilder.build(), title: Localized(.tab_bar_screen_favorite), image: UIImage(systemName: "star")),
        ]
    }
    
    func createNavigationController(for rootViewController: UIViewController,
                                    title: String,
                                    image: UIImage?) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }
}
