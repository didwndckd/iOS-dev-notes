import SwiftUI
import UIKit

final class ACoordinator: Coordinator, ARouting {
    private let navigationController: UINavigationController
    private var cameraPickerCoordinator: CameraPickerCoordinator?

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
