import Combine
import UIKit

protocol BRouting: AnyObject {
    func openCamera(allowsEditing: Bool, completion: @escaping (UIImage?) -> Void)
}

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
