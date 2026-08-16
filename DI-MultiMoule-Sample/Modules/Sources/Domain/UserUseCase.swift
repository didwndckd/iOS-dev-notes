import DI

public protocol UserUseCase: Sendable {
    func excute() async throws -> User
}

public struct UserUseCaseImpl: UserUseCase {
    @DI(\.userRepository)
    private var repo
    
    public init() {}
    
    public func excute() async throws -> User {
        try await repo.fetchUser()
    }
}

public enum UserUseCaseKey: DIKey {
    public static let defaultValue: any UserUseCase = UserUseCaseImpl()
}

public extension DIValues {
    var userUseCase: any UserUseCase {
        get { self[UserUseCaseKey.self] }
        set { self[UserUseCaseKey.self] = newValue }
    }
}
