public protocol UserUseCase: Sendable {
    func excute() async throws -> User
}

public struct UserUseCaseImpl: UserUseCase {
    private let repo: any UserRepository

    public init(repo: any UserRepository) {
        self.repo = repo
    }

    public func excute() async throws -> User {
        try await repo.fetchUser()
    }
}
