import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MockedMacros)
import MockedMacros

let testMacros: [String: Macro.Type] = [
    "Mocked": MockedMacro.self,
]
#endif

final class MockedTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MockedMacros)
        assertMacroExpansion(
            """
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
            """,
            expandedSource: """
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

            /// Mocked version of SomeParameter
            struct MockedSomeParameter: SomeParameter {
                // MARK: - MockedSomeParameter Variables

                var title: String
                var description: String

                // MARK: - MockedSomeParameter Function Overrides

                private let someMethodOverride: (@Sendable () -> Void)?
                private let someMethodOverrideParameter: (@Sendable (_ parameter: Int) -> Void)?
                private let someMethodOverrideWith: (@Sendable (_ with: Int) -> Void)?
                private let someOtherMethodOverrideThrows: (@Sendable () throws -> String)?
                private let someOtherMethodOverrideAsyncThrows: (@Sendable () async throws -> String)?
                private let someAsyncMethodOverrideAsync: (@Sendable () async -> String)?
                private let someOptionalMethodOverride: (@Sendable () -> String?)?

                // MARK: - MockedSomeParameter init

                init(
                    title: String ,
                    description: String ,
                    someMethod: (@Sendable () -> Void)? = nil,
                    someMethodParameter: (@Sendable (_ parameter: Int) -> Void)? = nil,
                    someMethodWith: (@Sendable (_ with: Int) -> Void)? = nil,
                    someOtherMethodThrows: (@Sendable () throws -> String)? = nil,
                    someOtherMethodAsyncThrows: (@Sendable () async throws -> String)? = nil,
                    someAsyncMethodAsync: (@Sendable () async -> String)? = nil,
                    someOptionalMethod: (@Sendable () -> String?)? = nil
                ) {
                    self.title = title
                    self.description = description
                    self.someMethodOverride = someMethod
                    self.someMethodOverrideParameter = someMethodParameter
                    self.someMethodOverrideWith = someMethodWith
                    self.someOtherMethodOverrideThrows = someOtherMethodThrows
                    self.someOtherMethodOverrideAsyncThrows = someOtherMethodAsyncThrows
                    self.someAsyncMethodOverrideAsync = someAsyncMethodAsync
                    self.someOptionalMethodOverride = someOptionalMethod
                }


                // MARK: - MockedSomeParameter Functions

                func someMethod() -> Void {
                guard let someMethodOverride else {
                    fatalError("Mocked someMethod: (@Sendable () -> Void)? was not implemented!")
                }

                return someMethodOverride()
                }

                func someMethod(
                    parameter: Int
                ) -> Void {
                    guard let someMethodOverrideParameter else {
                        fatalError("Mocked someMethodParameter: (@Sendable (_ parameter: Int) -> Void)? was not implemented!")
                    }

                    return someMethodOverrideParameter(
                        parameter
                    )
                }

                func someMethod(
                    with: Int
                ) -> Void {
                    guard let someMethodOverrideWith else {
                        fatalError("Mocked someMethodWith: (@Sendable (_ with: Int) -> Void)? was not implemented!")
                    }

                    return someMethodOverrideWith(
                        with
                    )
                }

                func someOtherMethod() throws -> String {
                    guard let someOtherMethodOverrideThrows else {
                        fatalError("Mocked someOtherMethodThrows: (@Sendable () throws -> String)? was not implemented!")
                    }

                    return try someOtherMethodOverrideThrows()
                }

                func someOtherMethod() async throws -> String {
                    guard let someOtherMethodOverrideAsyncThrows else {
                        fatalError("Mocked someOtherMethodAsyncThrows: (@Sendable () async throws -> String)? was not implemented!")
                    }

                    return try await someOtherMethodOverrideAsyncThrows()
                }

                func someAsyncMethod() async -> String {
                    guard let someAsyncMethodOverrideAsync else {
                        fatalError("Mocked someAsyncMethodAsync: (@Sendable () async -> String)? was not implemented!")
                    }

                    return await someAsyncMethodOverrideAsync()
                }

                func someOptionalMethod() -> String? {
                    guard let someOptionalMethodOverride else {
                        fatalError("Mocked someOptionalMethod: (@Sendable () -> String?)? was not implemented!")
                    }

                    return someOptionalMethodOverride()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
