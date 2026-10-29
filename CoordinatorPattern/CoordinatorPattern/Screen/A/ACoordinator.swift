import SwiftUI
import UIKit

final class ACoordinator: Coordinator, CoordinatorContainer, ARouting {
    var rootViewController: UIViewController { navigationController }
    var childCoordinators: [any Coordinator] = []

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = AViewModel()
        viewModel.coordinator = self
        let viewController = UIHostingController(rootView: AView(viewModel: viewModel))
        viewController.title = viewModel.title
        navigationController.tabBarItem = UITabBarItem(
            title: viewModel.title,
            image: UIImage(systemName: "a.circle"),
            tag: 0
        )
        navigationController.setViewControllers([viewController], animated: false)
    }
}
