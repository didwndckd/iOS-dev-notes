import Domain
import Data
import NeedleFoundation

// 외부에서 요구하는 의존성이 없는 데이터 스코프.
final class DataComponent: Component<EmptyDependency> {
    public var userRepository: any UserRepository {
        return UserRepositoryImpl()
    }
}
