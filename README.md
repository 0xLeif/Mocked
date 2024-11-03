# Mocked

[![macOS Build](https://img.shields.io/github/actions/workflow/status/0xLeif/Mocked/macOS.yml?label=macOS&branch=main)](https://github.com/0xLeif/Mocked/actions/workflows/macOS.yml)
[![Ubuntu Build](https://img.shields.io/github/actions/workflow/status/0xLeif/Mocked/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/0xLeif/Mocked/actions/workflows/ubuntu.yml)
[![License](https://img.shields.io/github/license/0xLeif/Mocked)](https://github.com/0xLeif/Mocked/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/0xLeif/Mocked)](https://github.com/0xLeif/Mocked/releases)

Mocked is a Swift compiler macro that automatically generates mock implementations for protocols. This can be especially useful for unit testing, allowing you to easily create mock objects to verify behavior and interactions in your tests.

## Features

- **Automatic Mock Generation**: Simply annotate your protocol with `@Mocked`, and a mock implementation will be generated.
- **Supports Properties and Methods**: Generates mock versions of properties and methods, including `async` and `throws` variants.
- **Configurable Behavior**: Easily override behavior by providing closures during initialization of the mock.

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

### Edge Cases and Warnings

- **Non-Protocol Usage**: The `@Mocked` macro can only be applied to protocols. Using it on other types will result in a compilation error.
- **Unimplemented Methods**: Any method that is not overridden will call `fatalError()` if invoked. Ensure all required methods are implemented when using the generated mock.
- **Async and Throwing Methods**: The generated mocks handle `async` and `throws` methods appropriately, but be sure to provide closures that match the method signatures.

## Contributing

Contributions are welcome! If you have suggestions, issues, or improvements, feel free to open a pull request or issue on the [GitHub repository](https://github.com/0xLeif/Mocked).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

