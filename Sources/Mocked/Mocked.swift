/**
# `Mocked` Macro Documentation

The `Mocked` macro is a powerful tool used to automatically generate a mocked implementation of a protocol, simplifying unit testing by creating mock objects without the need for cumbersome manual coding. This macro includes support for associated types and automatic detection of class requirements, providing flexibility in testing and making it ideal for developers looking to reduce boilerplate and focus on writing effective tests.

## Features

- **Automatic Mock Generation**: The `Mocked` macro automatically generates a mock implementation for any protocol. This saves development time and reduces the amount of boilerplate code required for creating mock objects.
- **Access Level Control**: You can specify the access level (`open`, `public`, `package`, `internal`, `fileprivate`, `private`) for the generated mock, making it suitable for different testing needs and code visibility requirements.
- **Closure-Based Method Overrides**: Methods and properties of the protocol can be overridden by providing closures during the initialization of the generated mock, allowing precise control over method behavior in tests.
- **Support for Associated Types**: The `Mocked` macro handles protocols with associated types using generics, offering flexibility for mocking complex protocol requirements.
- **Automatic Detection of Class Requirements**: If the protocol conforms to `AnyObject`, the macro generates a class instead of a struct, ensuring reference semantics are preserved where needed.
- **Support for `async` and `throws` Methods**: The generated mock can handle methods marked as `async` or `throws`, allowing you to create mock behaviors for asynchronous operations or error scenarios.
- **Automatic Default Property Implementations**: Properties defined in the protocol are automatically backed by straightforward storage, which can be accessed and modified as needed.

## Usage

To use the `@Mocked` macro, simply attach it to a protocol declaration. The generated mock will provide all properties and methods specified in the protocol, which can be customized through closures provided during initialization. This allows for easy setup of mock behavior for testing.

### Example:

```swift
@Mocked
protocol MyProtocol {
    var title: String { get set }
    func performAction() -> Void
}
```

The code above will generate a `MockedMyProtocol` struct that implements `MyProtocol`. This struct allows defining the behavior of `performAction()` by providing a closure during initialization, making it easy to set up test scenarios without extensive boilerplate code.

### Example of Generated Code:

```swift
struct MockedMyProtocol: MyProtocol {
    // Properties defined by the protocol
    var title: String

    // Closure to override the behavior of `performAction()`
    private let performActionOverride: (() -> Void)?

    // Initializer to provide custom behavior for each method or property
    init(title: String, performAction: (() -> Void)? = nil) {
        self.title = title
        self.performActionOverride = performAction
    }

    // Method implementation that uses the provided closure or triggers a `fatalError`
    func performAction() {
        guard let performActionOverride else {
            fatalError("Mocked performAction was not implemented!")
        }
        performActionOverride()
    }
}
```

## Access Level Control

The `@Mocked` macro allows specifying an access level for the generated mock. This can be useful when defining the visibility of mocks in your test suite or modules. The following access levels are supported:

- `open`: The most permissive access level, allowing subclassing and usage in other modules.
- `public`: Allows usage by other modules but restricts subclassing to within the defining module.
- `package`: Limits access to declarations within the same package, suitable for managing code visibility within related modules.
- `internal`: The default access level in Swift, exposing the mock only within the same module.
- `fileprivate`: Restricts access to the file where the mock is defined.
- `private`: Restricts access to the enclosing declaration, providing the highest level of encapsulation.

To specify an access level, provide it as a parameter to the macro:

```swift
@Mocked(.public)
protocol MyProtocol {
    // Protocol requirements
}
```

## Edge Cases and Warnings

- **Non-Protocol Usage**: The `@Mocked` macro can only be applied to protocol definitions. Applying it to other types, such as classes or structs, will result in a compilation error.
- **Unimplemented Methods**: Any method that is not explicitly overridden will call `fatalError()` when invoked, ensuring that developers are alerted if a method is called without being properly mocked. Always ensure that all necessary methods are mocked to avoid runtime crashes.
- **Value vs. Reference Semantics**: The generated mock defaults to being a struct, which means it follows value semantics. If the protocol requires reference semantics (e.g., it conforms to `AnyObject`), the macro will generate a class instead.

## Best Practices

- **Keep Protocols Small and Focused**: Define small, focused protocols that capture a specific piece of functionality. This makes the generated mocks easier to use and understand.
- **Avoid Over-Mocking**: Mock only the behavior required for the test. Over-mocking can lead to brittle tests that are difficult to maintain.
- **Use Closures Thoughtfully**: When providing closures to override protocol methods, simulate realistic behaviors to create meaningful tests. For example, introduce delays for `async` methods or specific error types for `throws` methods.

## Advanced Usage

The `Mocked` macro can handle more complex protocols, including those with associated types, `async` methods, `throws` methods, or combinations of these. This makes it easy to test scenarios involving asynchronous operations, error handling, or protocols with type constraints.

```swift
@Mocked
protocol ComplexProtocol {
    associatedtype ItemType
    func fetchData() async throws -> ItemType
    func processData(input: Int) -> Bool
}

let mock = MockedComplexProtocol<String>(
    fetchData: { return "Mocked Data" },
    processData: { input in return input > 0 }
)
```

In this example, `MockedComplexProtocol` provides custom behavior for `fetchData` and `processData`, allowing precise control over how the protocol's methods behave in your tests.

## Limitations

- **Associated Types**: While the `Mocked` macro supports protocols with associated types using generics, there may be scenarios where creating a type-erased wrapper could be beneficial, especially for protocols with complex relationships between associated types.
- **Protocol Inheritance**: The `Mocked` macro will not automatically generate parent mocks for child protocols that inherit other protocols. Developers need to extend the generated mock to meet the requirements of inherited protocols manually.
*/
@attached(peer, names: prefixed(Mocked))
public macro Mocked(_ accessLevel: AccessLevel = .internal) = #externalMacro(
    module: "MockedMacros",
    type: "MockedMacro"
)
