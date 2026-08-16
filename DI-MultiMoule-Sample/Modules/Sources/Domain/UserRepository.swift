//
//  UserRepository.swift
//  DIMultiModuleSample
//
//  Created by yjc on 8/17/26.
//

import DI

public protocol UserRepository: Sendable {
    func fetchUser() async throws -> User
}

public enum UserRepositoryKey: DIKey {
    public static var defaultValue: any UserRepository { fatalError() }
}

public extension DIValues {
    var userRepository: any UserRepository {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }
}
