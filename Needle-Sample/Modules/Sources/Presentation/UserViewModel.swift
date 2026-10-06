import Foundation
import Domain

@MainActor
@Observable
public final class UserViewModel {
    private let useCase: any UserUseCase

    private(set) var user: User?

    public init(useCase: any UserUseCase) {
        self.useCase = useCase
    }

    func load() async {
        user = try? await useCase.excute()
    }
}
