import Mocked

protocol ThisBreaksShit {
    var broken: String { get }
}

@Mocked
protocol SomeParameter: Sendable {
    var title: String { get set }
    var description: String { get }

    func someMethod()
    func someMethod(parameter: Int)
    func someMethod(with parameter: Int)

    func someOtherMethod() throws -> String
    func someOtherMethod() async throws -> String

    func someAsyncMethod() async -> String

    func someOptionalMethod() -> String?
}

Task { @MainActor in
    let mockedParameter = MockedSomeParameter(
        title: "Hello",
        description: "Descrip",
        someMethodParameter: { print("\($0)") },
        someOtherMethodAsyncThrows: { "?" }
    )

    mockedParameter.someMethod(parameter: 3)
    let value = try await mockedParameter.someOtherMethod()

    print(value)

}
