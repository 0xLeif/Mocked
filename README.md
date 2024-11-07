# Mocked

[![macOS Build](https://img.shields.io/github/actions/workflow/status/0xLeif/Mocked/macOS.yml?label=macOS&branch=main)](https://github.com/0xLeif/Mocked/actions/workflows/macOS.yml)
[![Ubuntu Build](https://img.shields.io/github/actions/workflow/status/0xLeif/Mocked/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/0xLeif/Mocked/actions/workflows/ubuntu.yml)
[![Windows Build](https://img.shields.io/github/actions/workflow/status/0xLeif/Mocked/windows.yml?label=Windows&branch=main)](https://github.com/0xLeif/Mocked/actions/workflows/windows.yml)
[![License](https://img.shields.io/github/license/0xLeif/Mocked)](https://github.com/0xLeif/Mocked/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/0xLeif/Mocked)](https://github.com/0xLeif/Mocked/releases)

Mocked is a Swift 6 compiler macro that automatically generates mock implementations for protocols. This can be especially useful for unit testing, allowing you to easily create mock objects to verify behavior and interactions in your tests.

## Features

- **Automatic Mock Generation**: Simply annotate your protocol with `@Mocked`, and a mock implementation will be generated.
- **Supports Properties and Methods**: Generates mock versions of properties and methods, including `async` and `throws` variants.
- **Access Level Control**: You can specify the access level (`open`, `public`, `package`, `internal`, `fileprivate`, `private`) for the generated mock.
- **Configurable Behavior**: Easily override behavior by providing closures during initialization of the mock.
- **Support for Associated Types**: The `Mocked` macro handles protocols with associated types using generics.
- **Automatic Detection of Class Requirements**: If the protocol conforms to `AnyObject`, a class is generated instead of a struct, maintaining reference semantics.
- **Automatic Default Property Implementations**: Properties are backed by straightforward storage for easy access and modification.

## Installation

To use Mocked in your project, add it as a dependency using Swift Package Manager. Add the following to your `Package.swift` file:

```swift
.package(url: "https://github.com/0xLeif/Mocked.git", from: "1.0.0")
```

And add it as a dependency to your target:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        "Mocked"
    ]
)
```

## Usage

To generate a mock for a protocol, simply annotate it with `@Mocked`:

```swift
@Mocked
protocol MyProtocol {
    var title: String { get set }
    func performAction() -> Void
}
```

This will generate a mock struct named `MockedMyProtocol` that conforms to `MyProtocol`. You can use this mock in your unit tests to validate behavior.

### Example

```swift
@Mocked
protocol MyProtocol {
    var title: String { get set }
    func performAction() -> Void
}

let mock = MockedMyProtocol(
    title: "Test Title",
    performAction: { print("Action performed") }
)

mock.performAction()  // Output: "Action performed"
```

### Default Implementations

If a protocol has a default implementation provided in an extension, the generated mock will use this default implementation unless an override is specified.

```swift
protocol DefaultProtocol {
    func defaultMethod() -> String
}

extension DefaultProtocol {
    func defaultMethod() -> String {
        return "default"
    }
}

@Mocked
protocol CustomProtocol: DefaultProtocol {
    func customMethod() -> Bool
}

let mock = MockedCustomProtocol(
    customMethod: { true }
)

print(mock.defaultMethod())  // Output: "default"
```

### Advanced Usage

The `Mocked` macro can be used with more complex protocols, including those with associated types, `async` methods, `throws` methods, or a combination of both.

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

### Edge Cases and Warnings

- **Non-Protocol Usage**: The `@Mocked` macro can only be applied to protocols. Using it on other types will result in a compilation error.
- **Unimplemented Methods**: Any method that is not overridden will call `fatalError()` if invoked. Ensure all required methods are implemented when using the generated mock.
- **Async and Throwing Methods**: The generated mocks handle `async` and `throws` methods appropriately, but be sure to provide closures that match the method signatures.

## Limitations

- **No Function-Level Generics**: Generics are supported only at the protocol level using associated types. Function-level generics are not currently supported. If you need generic capabilities, consider using associated types in the protocol.
- **Child Protocols Cannot Mock Parent Requirements**: When mocking protocols that inherit from other protocols, the `@Mocked` macro will not automatically generate implementations for the inherited protocol requirements.
- **No Support for `@` Annotations**: Attributes such as `@MainActor` are not currently supported in mock generation.

## Contributing

Contributions are welcome! If you have suggestions, issues, or improvements, feel free to open a pull request or issue on the [GitHub repository](https://github.com/0xLeif/Mocked).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

