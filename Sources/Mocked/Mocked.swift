/// The `Mocked` macro is used to automatically generate a mocked implementation of a protocol.
///
/// This macro attaches a peer struct prefixed with `Mocked` that provides implementations of all the methods and properties defined in the protocol.
///
/// # Usage
/// Apply the `@Mocked` attribute to a protocol declaration to generate a mock implementation of that protocol. This mock implementation can be used for unit testing purposes to easily verify interactions with the protocol methods and properties.
///
/// Example:
/// ```swift
/// @Mocked
/// protocol MyProtocol {
///     var title: String { get set }
///     func performAction() -> Void
/// }
/// ```
///
/// The code above will generate a `MockedMyProtocol` struct that implements `MyProtocol`.
///
/// # Edge Cases and Warnings
/// - **Non-Protocol Usage**: This macro can only be applied to protocol definitions. Attempting to use it on other types, such as classes or structs, will lead to a compilation error.
/// - **Unimplemented Methods**: Any method that is not explicitly overridden will call `fatalError()` when invoked, which will crash the program. Ensure all necessary methods are mocked when using the generated struct.
/// - **Async and Throwing Methods**: The macro correctly handles protocols with `async` and/or `throws` functions. Be mindful to provide appropriate closures during initialization.
///
/// # Example of Generated Code
/// For the protocol `MyProtocol`, the generated mock implementation would look like this:
/// ```swift
/// struct MockedMyProtocol: MyProtocol {
///     var title: String
///     private let performActionOverride: (() -> Void)?
///
///     init(title: String, performAction: (() -> Void)? = nil) {
///         self.title = title
///         self.performActionOverride = performAction
///     }
///
///     func performAction() {
///         guard let performActionOverride else {
///             fatalError("Mocked performAction was not implemented!")
///         }
///         performActionOverride()
///     }
/// }
/// ```
@attached(peer, names: prefixed(Mocked))
public macro Mocked() = #externalMacro(
    module: "MockedMacros",
    type: "MockedMacro"
)
