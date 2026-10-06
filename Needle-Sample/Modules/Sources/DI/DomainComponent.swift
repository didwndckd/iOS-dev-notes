//
//  File.swift
//  NeedleSample
//
//  Created by yjc on 10/7/26.
//

import Domain
import NeedleFoundation

protocol DomainDependency: Dependency {
    var userRepository: any UserRepository { get }
}

final class DomainComponent: Component<DomainDependency> {
    var userUseCase: any UserUseCase {
        UserUseCaseImpl(repo: dependency.userRepository)
    }
}
