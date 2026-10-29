import Combine
import UIKit

protocol BRouting: AnyObject, CameraRoute {}

final class BViewModel: ObservableObject {
    let title = "B"
    weak var coordinator: (any BRouting)?

    @Published var allowsEditing = false
    @Published private(set) var image: UIImage?

    func didTapCamera() {
        coordinator?.openCamera(allowsEditing: allowsEditing) { [weak self] image in
            guard let image else { return }
            self?.image = image
        }
    }
}
