// The Swift Programming Language
// https://docs.swift.org/swift-book

/// 依赖容器
public final class DependencyContainer {
    public static let shared = DependencyContainer()

    private var registry: [ObjectIdentifier: Any] = [:]

    /// 注册协议实现
    public func register<Protocol>(
        _ protocolType: Protocol.Type,
        implementation: @autoclosure @escaping () -> Protocol
    ) {
        let key = ObjectIdentifier(Protocol.self)
        registry[key] = implementation
    }

    /// 解析协议实现
    public func resolve<Protocol>(_ protocolType: Protocol.Type = Protocol.self) -> Protocol {
        let key = ObjectIdentifier(Protocol.self)
        guard let implementation = registry[key] as? () -> Protocol else {
            fatalError("未找到 \(Protocol.self) 的注册实现")
        }
        return implementation()
    }
}

/// 注入属性包装器简化访问
@propertyWrapper
public struct Inject<Value> {
    public var wrappedValue: Value

    public init() {
        self.wrappedValue = DependencyContainer.shared.resolve()
    }
}
