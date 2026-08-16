//
//  File.swift
//  DIMultiModuleSample
//
//  Created by yjc on 8/17/26.
//

import Foundation
import DI
import Data
import Domain
import Presentation

public enum DIContainer {
    static var liveDataValues: DIValues {
        var values = DIValues()
        values.userRepository = UserRepositoryImpl()
        return values
    }
    
    static var liveDomainValues: DIValues {
        return DIContext.$current.withValue(liveDataValues) {
            var values = DIContext.current
            values.userUseCase = UserUseCaseImpl()
            return values
        }
    }
    
    @MainActor
    public static var userViewModel: UserViewModel {
        return DIContext.$current.withValue(liveDomainValues) {
            return UserViewModel()
        }
    }
}
