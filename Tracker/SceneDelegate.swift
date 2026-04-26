

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)

        let trackerStore = TrackerStore(context: CoreDataStack.shared.context)

        let trackersVC = TrackersViewController(trackerStore: trackerStore)
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle"),
            selectedImage: nil
        )
        
        let statsVC = StatisticsViewController()
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare"),
            selectedImage: nil
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [trackersNav, statsNav]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

}

