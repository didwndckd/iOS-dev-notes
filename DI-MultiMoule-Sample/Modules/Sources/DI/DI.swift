
@propertyWrapper
public struct DI<Value>: Sendable {
    private var values = DIContext.current
    private let keyPath: KeyPath<DIValues, Value> & Sendable

    public init(_ keyPath: KeyPath<DIValues, Value> & Sendable) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        values[keyPath: keyPath]
    }
}

// DI
public protocol DIKey: Sendable {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
}

// DI
public struct DIValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]
    
    public init() {}

    public subscript<Key: DIKey>(_ key: Key.Type) -> Key.Value {
        get {
            storage[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

// DI
public enum DIContext: Sendable {
    @TaskLocal
    public static var current = DIValues()
}
