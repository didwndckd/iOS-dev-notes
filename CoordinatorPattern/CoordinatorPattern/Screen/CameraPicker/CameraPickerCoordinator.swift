//
//  CameraPickerCoordinator.swift
//  CoordinatorPattern
//
//  Created by yjc on 10/29/26.
//

import UIKit

final class CameraPickerCoordinator: NSObject, Coordinator {
    private let hostViewController: UIViewController
    private let allowsEditing: Bool
    private let completion: (CameraPickerCoordinator, UIImage?) -> Void

    init(hostViewController: UIViewController, allowsEditing: Bool = false, completion: @escaping (CameraPickerCoordinator, UIImage?) -> Void) {
        self.hostViewController = hostViewController
        self.allowsEditing = allowsEditing
        self.completion = completion
    }

    deinit {
        print("CameraPickerCoordinator deinit")
    }

    func start() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(self, nil)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = allowsEditing
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self
        hostViewController.present(picker, animated: true)
    }
}

extension CameraPickerCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true) { [self] in
            completion(self, image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [self] in
            completion(self, nil)
        }
    }
}

protocol CameraRoute {
    func openCamera(allowsEditing: Bool, completion: @escaping (UIImage?) -> Void)
}

extension CameraRoute where Self: CoordinatorContainer {
    func openCamera(allowsEditing: Bool, completion: @escaping (UIImage?) -> Void) {
        guard rootViewController.presentedViewController == nil else { return }

        let coordinator = CameraPickerCoordinator(
            hostViewController: rootViewController,
            allowsEditing: allowsEditing
        ) { [weak self] child, image in
            self?.end(child: child)
            completion(image)
        }
        start(child: coordinator)
    }
}
