/**
The `Mocked` macro is used to automatically generate a mocked implementation of a protocol, including support for associated types and automatic detection of class requirements.

This macro attaches a peer struct or class prefixed with `Mocked`, which provides implementations of all the methods and properties defined in the protocol. This is particularly useful for unit testing, where creating mock objects manually can be cumbersome and error-prone. With `@Mocked`, developers can easily generate mock implementations that allow precise control over protocol methods and properties, enabling more effective and focused testing.

# Usage
Apply the `@Mocked` attribute to a protocol declaration to generate a mock implementation of that protocol. The generated mock will have the same properties and methods as the protocol, but they can be overridden through closures provided during initialization. This mock implementation can be used for unit testing purposes to easily verify interactions with the protocol methods and properties.

Example:
```swift
@Mocked
protocol MyProtocol {
    var title: String { get set }
    func performAction() -> Void
}
```

The code above will generate a `MockedMyProtocol` struct that implements `MyProtocol`. This struct allows defining the behavior of `performAction()` by providing a closure during initialization, making it easy to set up test scenarios without writing extensive boilerplate code.

# Features
The `@Mocked` macro provides several key features:

- **Automatic Mock Generation**: Generates a mock implementation for any protocol, saving time and reducing boilerplate code.
- **Closure-Based Method Overrides**: Methods and properties can be overridden by providing closures during mock initialization, giving you full control over method behavior in different test scenarios.
- **Support for Associated Types**: Handles protocols with associated types by using Swift generics, providing flexibility for complex protocol requirements.
- **Automatic Detection of Class Requirements**: If the protocol conforms to `AnyObject`, the macro generates a class instead of a struct, ensuring reference semantics are maintained where needed.
- **Support for `async` and `throws` Methods**: The generated mock can handle methods marked as `async` or `throws`, allowing you to create mock behaviors that include asynchronous operations or errors.
- **Automatic Default Property Implementations**: Provides straightforward storage for properties defined in the protocol, which can be accessed and modified as needed.

# Edge Cases and Warnings
- **Non-Protocol Usage**: This macro can only be applied to protocol definitions. Attempting to use it on other types, such as classes or structs, will lead to a compilation error.
- **Unimplemented Methods**: Any method that is not explicitly overridden will call `fatalError()` when invoked, which will crash the program. This behavior is intentional to alert developers that the method was called without being properly mocked. Always ensure that all necessary methods are mocked when using the generated struct to avoid runtime crashes. Mocks should only be used in tests or previews, where such crashes are acceptable for ensuring proper setup.
- **Async and Throwing Methods**: Be mindful to provide appropriate closures during initialization to match the behavior of `async` or `throws` methods. If no closure is provided, the default behavior will result in a `fatalError()`.
- **Value vs. Reference Semantics**: The generated mock defaults to being a struct, which means it follows value semantics. If the protocol requires reference semantics (e.g., it conforms to `AnyObject`), the macro will generate a class instead.

# Example of Generated Code
For the protocol `MyProtocol`, the generated mock implementation would look like this:
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

In the generated code:
- The `title` property is stored directly within the struct, allowing you to get or set its value just like a normal property.
- The `performAction` method uses a closure (`performActionOverride`) provided during initialization. If no closure is provided, calling `performAction()` will result in a `fatalError`, ensuring you never accidentally call an unmocked method.

# Advanced Usage
The `Mocked` macro can be used with more complex protocols, including those with associated types, `async` methods, `throws` methods, or a combination of both. This allows developers to test various scenarios, such as successful asynchronous operations or handling errors, without needing to write dedicated mock classes manually.

```swift
@Mocked
protocol ComplexProtocol {
    associatedtype ItemType
    associatedtype ItemValue: Codable
    func fetchData() async throws -> ItemType
    func processData(input: Int) -> Bool
    func storeValue(value: ItemValue) -> Void
}

let mock = MockedComplexProtocol<String, Int>(
    fetchData: { return "Mocked Data" },
    processData: { input in return input > 0 }
)

// Usage in a test
Task {
    do {
        let data = try await mock.fetchData()
        print(data)  // Output: "Mocked Data"
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}

let isValid = mock.processData(input: 5)
XCTAssertTrue(isValid)
```

# Limitations
- **Associated Types**: The `@Mocked` macro currently supports protocols with associated types using generics. However, there may be scenarios where creating a type-erased wrapper could be beneficial, especially for protocols with complex associated type relationships.
- **Protocol Inheritance**: When mocking protocols that inherit from other protocols, the `@Mocked` macro will not automatically generate parent mocks for child protocols. Instead, extend the parent protocols or the child protocol to provide the necessary values or functions to conform to the inherited requirements.

# Best Practices
- **Define Clear Protocols**: Define small, focused protocols that capture a specific piece of functionality. This makes the generated mocks easier to use and understand.
- **Avoid Over-Mocking**: Avoid mocking too much behavior in a single test, as it can lead to brittle tests that are difficult to maintain. Instead, focus on the specific interactions you want to verify.
- **Use Closures Thoughtfully**: Provide closures that simulate realistic behavior to make your tests more meaningful. For example, simulate network delays with `async` closures or return specific error types to test error handling paths.
*/
@attached(peer, names: prefixed(Mocked))
public macro Mocked() = #externalMacro(
    module: "MockedMacros",
    type: "MockedMacro"
)
