import SwiftUI
import UIKit

final class BCoordinator: Coordinator, BRouting {
    private let navigationController: UINavigationController
    private var cameraPickerCoordinator: CameraPickerCoordinator?

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

    func openCamera(allowsEditing: Bool, completion: @escaping (UIImage?) -> Void) {
        guard cameraPickerCoordinator == nil,
              navigationController.presentedViewController == nil else { return }

        let coordinator = CameraPickerCoordinator(
            hostViewController: navigationController,
            allowsEditing: allowsEditing
        ) { [weak self] image in
            self?.cameraPickerCoordinator = nil
            completion(image)
        }
        cameraPickerCoordinator = coordinator
        coordinator.start()
    }
}
