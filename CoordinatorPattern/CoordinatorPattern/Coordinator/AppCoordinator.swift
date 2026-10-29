//
//  AppCoordinator.swift
//  CoordinatorPattern
//
//  Created by yjc on 10/29/26.
//

import UIKit

final class AppCoordinator: Coordinator, CoordinatorContainer {
    var rootViewController: UIViewController { tabbarController }
    var childCoordinators: [any Coordinator] = []

    private let window: UIWindow
    private let tabbarController: UITabBarController

    init(window: UIWindow) {
        self.window = window
        self.tabbarController = UITabBarController()
    }

    func start() {
        window.rootViewController = tabbarController
        let aNavigationController = UINavigationController()
        let bNavigationController = UINavigationController()
        let aCoordinator = ACoordinator(navigationController: aNavigationController)
        let bCoordinator = BCoordinator(navigationController: bNavigationController)
        start(child: aCoordinator)
        start(child: bCoordinator)

        tabbarController.setViewControllers([
            aNavigationController,
            bNavigationController
        ], animated: false)
        window.makeKeyAndVisible()
    }
}
