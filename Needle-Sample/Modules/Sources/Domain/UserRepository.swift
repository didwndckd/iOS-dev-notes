public protocol UserRepository: Sendable {
    func fetchUser() async throws -> User
}
