//
//  AppCoordinator.swift
//  CoordinatorPattern
//
//  Created by yjc on 10/29/26.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let tabbarController: UITabBarController
    private var childCoordinators: [any Coordinator] = []

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
        childCoordinators = [aCoordinator, bCoordinator]
        childCoordinators.forEach { $0.start() }

        tabbarController.setViewControllers([
            aNavigationController,
            bNavigationController
        ], animated: false)
        window.makeKeyAndVisible()
    }
}
