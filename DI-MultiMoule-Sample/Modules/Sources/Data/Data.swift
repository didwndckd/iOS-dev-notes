import Domain

public struct UserRepositoryImpl: UserRepository {
    public init() {}
    
    public func fetchUser() async throws -> Domain.User {
        .init(id: 1)
    }
}
    
