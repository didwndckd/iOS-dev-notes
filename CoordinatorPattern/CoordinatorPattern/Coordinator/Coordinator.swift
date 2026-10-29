//
//  Coordinator.swift
//  CoordinatorPattern
//
//  Created by yjc on 10/29/26.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

protocol CoordinatorContainer: AnyObject {
    var rootViewController: UIViewController { get }
    var childCoordinators: [any Coordinator] { get set }
}

extension CoordinatorContainer {
    func start(child: some Coordinator) {
        childCoordinators.append(child)
        child.start()
    }

    func end(child: some Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}
