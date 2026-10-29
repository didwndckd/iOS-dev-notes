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
    private let completion: (UIImage?) -> Void

    init(hostViewController: UIViewController, allowsEditing: Bool = false, completion: @escaping (UIImage?) -> Void) {
        self.hostViewController = hostViewController
        self.allowsEditing = allowsEditing
        self.completion = completion
    }

    func start() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(nil)
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
        picker.dismiss(animated: true) { [completion] in
            completion(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [completion] in
            completion(nil)
        }
    }
}
