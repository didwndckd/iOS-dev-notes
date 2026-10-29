import SwiftUI
import UIKit

final class BCoordinator: Coordinator, CoordinatorContainer, BRouting {
    var rootViewController: UIViewController { navigationController }
    var childCoordinators: [any Coordinator] = []

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = BViewModel()
        viewModel.coordinator = self
        let viewController = UIHostingController(rootView: BView(viewModel: viewModel))
        viewController.title = viewModel.title
        navigationController.tabBarItem = UITabBarItem(
            title: viewModel.title,
            image: UIImage(systemName: "b.circle"),
            tag: 1
        )
        navigationController.setViewControllers([viewController], animated: false)
    }
}
