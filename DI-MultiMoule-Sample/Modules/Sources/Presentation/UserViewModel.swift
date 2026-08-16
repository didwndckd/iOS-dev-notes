import Foundation
import Domain
import DI

@MainActor
public final class UserViewModel: ObservableObject {
    @DI(\.userUseCase)
    private var useCase
    
    @Published private(set) var user: User?
    
    public init() {}
    
    func load() async {
        user = try? await useCase.excute()
    }
}
