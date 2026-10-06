//
//  PresentationComponent.swift
//  NeedleSample
//
//  Created by yjc on 10/7/26.
//

import Domain
import Presentation
import NeedleFoundation

protocol PresentationDependency: Dependency {
    var userUseCase: any UserUseCase { get }
}

@MainActor
final class PresentationComponent: Component<PresentationDependency> {
    var userViewModel: UserViewModel {
        UserViewModel(useCase: dependency.userUseCase)
    }
}
