import Domain
import NeedleFoundation

final class RootComponent: BootstrapComponent {
    // 자식은 부모를 보관하므로 Root가 자식 Component를 캐시하지 않는다.
    var dataComponent: DataComponent {
        return DataComponent(parent: self)
    }

    public var userRepository: any UserRepository {
        dataComponent.userRepository
    }
    
    var domainComponent: DomainComponent {
        DomainComponent(parent: self)
    }
    
    public var userUseCase: any UserUseCase {
        domainComponent.userUseCase
    }
    
    var presentationComponent: PresentationComponent {
        PresentationComponent(parent: self)
    }
}
