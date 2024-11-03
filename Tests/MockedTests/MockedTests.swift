import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MockedMacros)
import MockedMacros

let testMacros: [String: Macro.Type] = [
    "Mocked": MockedMacro.self,
]
#endif

final class MockedMacroTests: XCTestCase {
#if canImport(MockedMacros)
    func testSimpleProtocolMocking() throws {
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
                    title: String,
                    description: String,
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
                    with parameter: Int
                ) -> Void {
                    guard let someMethodOverrideWith else {
                        fatalError("Mocked someMethodWith: (@Sendable (_ with: Int) -> Void)? was not implemented!")
                    }
            
                    return someMethodOverrideWith(
                        parameter
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
    }
    
    func testComplexProtocolMocking() throws {
        assertMacroExpansion(
            """
            @Mocked
            protocol ExampleProtocol: Sendable {
                associatedtype ItemType
                associatedtype ItemValue: Codable
                associatedtype ItemKey: Hashable
            
                var name: String { get set }
                var count: Int { get }
                var isEnabled: Bool { get set }
            
                func fetchItem(withID id: Int) async throws -> ItemType
                func saveItem(_ item: ItemType) throws -> Bool
            
                func processAllItems() async
                func reset()
                func optionalItem() -> ItemType?
            }
            """,
            expandedSource: """
            protocol ExampleProtocol: Sendable {
                associatedtype ItemType
                associatedtype ItemValue: Codable
                associatedtype ItemKey: Hashable
            
                var name: String { get set }
                var count: Int { get }
                var isEnabled: Bool { get set }
            
                func fetchItem(withID id: Int) async throws -> ItemType
                func saveItem(_ item: ItemType) throws -> Bool
            
                func processAllItems() async
                func reset()
                func optionalItem() -> ItemType?
            }
            
            /// Mocked version of ExampleProtocol
            struct MockedExampleProtocol<ItemKey: Hashable, ItemType, ItemValue: Codable>: ExampleProtocol {
                // MARK: - MockedExampleProtocol Variables
            
                var name: String
                var count: Int
                var isEnabled: Bool
            
                // MARK: - MockedExampleProtocol Function Overrides
            
                private let fetchItemOverrideAsyncThrowsWithid: (@Sendable (_ withID: Int) async throws -> ItemType)?
                private let saveItemOverrideThrowsItem: (@Sendable (_ item: ItemType) throws -> Bool)?
                private let processAllItemsOverrideAsync: (@Sendable () async -> Void)?
                private let resetOverride: (@Sendable () -> Void)?
                private let optionalItemOverride: (@Sendable () -> ItemType?)?
            
                // MARK: - MockedExampleProtocol init
            
                init(
                    name: String,
                    count: Int,
                    isEnabled: Bool,
                    fetchItemAsyncThrowsWithid: (@Sendable (_ withID: Int) async throws -> ItemType)? = nil,
                    saveItemThrowsItem: (@Sendable (_ item: ItemType) throws -> Bool)? = nil,
                    processAllItemsAsync: (@Sendable () async -> Void)? = nil,
                    reset: (@Sendable () -> Void)? = nil,
                    optionalItem: (@Sendable () -> ItemType?)? = nil
                ) {
                    self.name = name
                    self.count = count
                    self.isEnabled = isEnabled
                    self.fetchItemOverrideAsyncThrowsWithid = fetchItemAsyncThrowsWithid
                    self.saveItemOverrideThrowsItem = saveItemThrowsItem
                    self.processAllItemsOverrideAsync = processAllItemsAsync
                    self.resetOverride = reset
                    self.optionalItemOverride = optionalItem
                }
            
            
                // MARK: - MockedExampleProtocol Functions
            
                func fetchItem(
                withID id: Int
                ) async throws -> ItemType {
                guard let fetchItemOverrideAsyncThrowsWithid else {
                    fatalError("Mocked fetchItemAsyncThrowsWithid: (@Sendable (_ withID: Int) async throws -> ItemType)? was not implemented!")
                }
            
                return try await fetchItemOverrideAsyncThrowsWithid(
                    id
                )
                }
            
                func saveItem(
                    _ item: ItemType
                ) throws -> Bool {
                    guard let saveItemOverrideThrowsItem else {
                        fatalError("Mocked saveItemThrowsItem: (@Sendable (_ item: ItemType) throws -> Bool)? was not implemented!")
                    }
            
                    return try saveItemOverrideThrowsItem(
                        item
                    )
                }
            
                func processAllItems() async -> Void {
                    guard let processAllItemsOverrideAsync else {
                        fatalError("Mocked processAllItemsAsync: (@Sendable () async -> Void)? was not implemented!")
                    }
            
                    return await processAllItemsOverrideAsync()
                }
            
                func reset() -> Void {
                    guard let resetOverride else {
                        fatalError("Mocked reset: (@Sendable () -> Void)? was not implemented!")
                    }
            
                    return resetOverride()
                }
            
                func optionalItem() -> ItemType? {
                    guard let optionalItemOverride else {
                        fatalError("Mocked optionalItem: (@Sendable () -> ItemType?)? was not implemented!")
                    }
            
                    return optionalItemOverride()
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testProtocolWithDefaultImplementation() throws {
        assertMacroExpansion(
                """
                protocol DefaultProtocol {
                    func defaultMethod() -> String
                }
                
                extension DefaultProtocol {
                    func defaultMethod() -> String {
                        return "default"
                    }
                }
                
                @Mocked
                protocol CustomProtocol: DefaultProtocol, AnyObject {
                    func customMethod() -> Bool
                }
                """,
                expandedSource: """
                protocol DefaultProtocol {
                    func defaultMethod() -> String
                }
                
                extension DefaultProtocol {
                    func defaultMethod() -> String {
                        return "default"
                    }
                }
                protocol CustomProtocol: DefaultProtocol, AnyObject {
                    func customMethod() -> Bool
                }
                
                /// Mocked version of CustomProtocol
                class MockedCustomProtocol: CustomProtocol {
                    // MARK: - MockedCustomProtocol Variables
                
                
                
                    // MARK: - MockedCustomProtocol Function Overrides
                
                    private let customMethodOverride: (() -> Bool)?
                
                    // MARK: - MockedCustomProtocol init
                
                    init(
                
                        customMethod: (() -> Bool)? = nil
                    ) {
                
                        self.customMethodOverride = customMethod
                    }
                
                
                    // MARK: - MockedCustomProtocol Functions
                
                    func customMethod() -> Bool {
                    guard let customMethodOverride else {
                        fatalError("Mocked customMethod: (() -> Bool)? was not implemented!")
                    }
                
                    return customMethodOverride()
                    }
                }
                """,
                macros: testMacros
        )
    }
#else
    func testSkippedDueToMissingMacros() throws {
        throw XCTSkip("macros are only supported when running tests for the host platform")
    }
#endif
}
