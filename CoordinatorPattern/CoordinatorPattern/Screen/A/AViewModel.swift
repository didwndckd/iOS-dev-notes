import Combine
import UIKit

protocol ARouting: AnyObject, CameraRoute {}

final class AViewModel: ObservableObject {
    let title = "A"
    weak var coordinator: (any ARouting)?

    @Published var allowsEditing = false
    @Published private(set) var image: UIImage?

    func didTapCamera() {
        coordinator?.openCamera(allowsEditing: allowsEditing) { [weak self] image in
            guard let image else { return }
            self?.image = image
        }
    }
}
