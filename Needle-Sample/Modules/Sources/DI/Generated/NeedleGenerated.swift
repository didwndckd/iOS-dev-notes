

import Data
import Domain
import NeedleFoundation
import Presentation

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Traversal Helpers

private func parent1(_ component: NeedleFoundation.Scope) -> NeedleFoundation.Scope {
    return component.parent
}

// MARK: - Providers

#if !NEEDLE_DYNAMIC

private class PresentationDependency0346b84a8e5bd52ac919Provider: PresentationDependency {
    var userUseCase: any UserUseCase {
        return rootComponent.userUseCase
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->PresentationComponent
private func factory3d71c0574c3a0140a19fb3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return PresentationDependency0346b84a8e5bd52ac919Provider(rootComponent: parent1(component) as! RootComponent)
}
private class DomainDependency119d2266219a87eee3b7Provider: DomainDependency {
    var userRepository: any UserRepository {
        return rootComponent.userRepository
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->DomainComponent
private func factory7ba960c8ef0cf1368c34b3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return DomainDependency119d2266219a87eee3b7Provider(rootComponent: parent1(component) as! RootComponent)
}

#else
extension RootComponent: NeedleFoundation.Registration {
    public func registerItems() {

        localTable["userRepository-any UserRepository"] = { [unowned self] in self.userRepository as Any }
        localTable["userUseCase-any UserUseCase"] = { [unowned self] in self.userUseCase as Any }
    }
}
extension DataComponent: NeedleFoundation.Registration {
    public func registerItems() {

    }
}
extension PresentationComponent: NeedleFoundation.Registration {
    public func registerItems() {
        keyPathToName[\PresentationDependency.userUseCase] = "userUseCase-any UserUseCase"
    }
}
extension DomainComponent: NeedleFoundation.Registration {
    public func registerItems() {
        keyPathToName[\DomainDependency.userRepository] = "userRepository-any UserRepository"
    }
}


#endif

private func factoryEmptyDependencyProvider(_ component: NeedleFoundation.Scope) -> AnyObject {
    return EmptyDependencyProvider(component: component)
}

// MARK: - Registration
private func registerProviderFactory(_ componentPath: String, _ factory: @escaping (NeedleFoundation.Scope) -> AnyObject) {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: componentPath, factory)
}

#if !NEEDLE_DYNAMIC

@inline(never) private func register1() {
    registerProviderFactory("^->RootComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootComponent->DataComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootComponent->PresentationComponent", factory3d71c0574c3a0140a19fb3a8f24c1d289f2c0f2e)
    registerProviderFactory("^->RootComponent->DomainComponent", factory7ba960c8ef0cf1368c34b3a8f24c1d289f2c0f2e)
}
#endif

public func registerProviderFactories() {
#if !NEEDLE_DYNAMIC
    register1()
#endif
}
