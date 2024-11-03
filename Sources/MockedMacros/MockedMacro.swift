import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The `MockedMacro` is a peer macro that generates a mocked implementation of a given protocol.
///
/// This macro can only be applied to protocols, and it creates a struct with mock implementations
/// of the protocol's methods and properties. The generated struct is named `Mocked<ProtocolName>`.
public struct MockedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure the macro is applied to a protocol
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            fatalError("MockedMacro can only be applied to protocols")
        }

        let mockClassName = "Mocked\(protocolDecl.name.text)"

        let members = protocolDecl.memberBlock.members

        // Variables

        let variables: [Variable] = variableBuilder(members: members)

        let variablesDefinitions: String = variableDefinitions(variables: variables)
        let variablesInitDefinitions: String = variablesInitDefinitions(variables: variables)
        let variablesInitAssignments: String = variablesInitAssignments(variables: variables)


        // Functions

        let functions: [Function] = functionBuilder(
            protocolDecl: protocolDecl,
            members: members
        )

        let functionVariableDefinitions: String = functionVariableDefinitions(functions: functions)
        let functionVariableInitDefinitions: String = functionVariableInitDefinitions(functions: functions)
        let functionVariableInitAssignments: String = functionVariableInitAssignments(functions: functions)
        let functionImplementations: String = functionImplementations(functions: functions)

        return [
            """
            /// Mocked version of \(raw: protocolDecl.name.text)
            struct \(raw: mockClassName): \(raw: protocolDecl.name.text) {
                // MARK: - \(raw: mockClassName) Variables
            
                \(raw: variablesDefinitions)
            
                // MARK: - \(raw: mockClassName) Function Overrides
            
                \(raw: functionVariableDefinitions)
            
                // MARK: - \(raw: mockClassName) init
            
                init(
                    \(raw: variablesInitDefinitions)
                    \(raw: functionVariableInitDefinitions)
                ) {
                    \(raw: variablesInitAssignments)
                    \(raw: functionVariableInitAssignments)
                }
             
                        
                // MARK: - \(raw: mockClassName) Functions
            
                \(raw: functionImplementations)
            }
            """
        ]
    }

    // MARK: - Variable helpers

    private static func variableBuilder(members:  MemberBlockItemListSyntax) -> [Variable] {
        members.compactMap { member in
            guard
                let variable = member.decl.as(VariableDeclSyntax.self)
            else { return nil }

            guard let binding = variable.bindings.first else {
                return nil
            }
            guard
                let typeAnnotation = binding.typeAnnotation?.type
            else {
                fatalError("\(String(describing: binding.initializer?.syntaxNodeType))")
            }

            let name = binding.pattern
            let type = typeAnnotation.description.trimmingCharacters(in: .whitespacesAndNewlines)

            return Variable(
                firstName: "\(name)",
                secondName: nil,
                type: type
            )
        }
    }

    private static func variableDefinitions(
        variables: [Variable]
    ) -> String {
        variables
            .map { "var \($0.declaration)" }
            .joined(separator: "\n")
    }

    private static func variablesInitDefinitions(
        variables: [Variable]
    ) -> String {
        variables
            .map { "\($0.declaration)," }
            .joined(separator: "\n")
    }

    private static func variablesInitAssignments(
        variables: [Variable]
    ) -> String {
        variables
            .map { "self.\($0.name) = \($0.name)" }
            .joined(separator: "\n")
    }

    // MARK: - Function helpers

    private static func functionBuilder(
        protocolDecl: ProtocolDeclSyntax,
        members:  MemberBlockItemListSyntax
    ) -> [Function] {
        let inheritsSendable = protocolDecl.inheritanceClause?.inheritedTypes.contains { inheritedType in
            inheritedType.type.description.trimmingCharacters(in: .whitespacesAndNewlines) == "Sendable"
        } ?? false

        return members.compactMap { member in
            guard
                let function = member.decl.as(FunctionDeclSyntax.self)
            else { return nil }

            let name = function.name.text
            var parameters: [Variable] = []
            let returnType = function.signature.returnClause?.type ?? "Void"

            let isAsync = function.signature.effectSpecifiers?.asyncSpecifier != nil
            let canThrow = function.signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil

            for parameter in function.signature.parameterClause.parameters {
                let parameterFirstName = parameter.firstName.text
                let parameterSecondName = parameter.secondName?.text
                let parameterType = parameter.type.description.trimmingCharacters(in: .whitespacesAndNewlines)

                parameters.append(
                    Variable(
                        firstName: parameterFirstName,
                        secondName: parameterSecondName,
                        type: parameterType
                    )
                )
            }

            return Function(
                name: "\(name)",
                parameters: parameters,
                isSendable: inheritsSendable,
                isAsync: isAsync,
                canThrow: canThrow,
                returnType: "\(returnType)"
            )
        }
    }

    private static func functionVariableDefinitions(
        functions: [Function]
    ) -> String {
        functions
            .map { "private let \($0.overrideClosure)" }
            .joined(separator: "\n")
    }

    private static func functionVariableInitDefinitions(
        functions: [Function]
    ) -> String {
        functions
            .map { "\($0.closure) = nil" }
            .joined(separator: ",\n")
    }

    private static func functionVariableInitAssignments(
        functions: [Function]
    ) -> String {
        functions
            .map { "self.\($0.overrideName) = \($0.uniqueName)" }
            .joined(separator: "\n")
    }

    private static func functionImplementations(
        functions: [Function]
    ) -> String {
        functions.map { function in
            let parameters: String = function.parameters
                .map { function in
                    "\(function.parameterName): \(function.type)"
                }
                .joined(separator: ", ")
            let parameterUsage: String = function.parameters
                .map(\.usageName)
                .joined(separator: ", ")


            let effectSignature: String = if function.canThrow && function.isAsync {
                "async throws "
            } else if function.canThrow {
                "throws "
            } else if function.isAsync {
                "async "
            } else {
                ""
            }

            let callSignature: String = if function.canThrow && function.isAsync {
                "try await "
            } else if function.canThrow {
                "try "
            } else if function.isAsync {
                "await "
            } else {
                ""
            }

            if parameters.isEmpty {
                return """
                    func \(function.name)() \(effectSignature)-> \(function.returnType ?? "Void") {
                        guard let \(function.overrideName) else {
                            fatalError("Mocked \(function.closure) was not implemented!")
                        }
                    
                        return \(callSignature)\(function.overrideName)()
                    }
                    """
            } else {
                return """
                    func \(function.name)(
                        \(parameters)
                    ) \(effectSignature)-> \(function.returnType ?? "Void") {
                        guard let \(function.overrideName) else {
                            fatalError("Mocked \(function.closure) was not implemented!")
                        }
                    
                        return \(callSignature)\(function.overrideName)(
                            \(parameterUsage)
                        )
                    }
                    """
            }
        }
        .joined(separator: "\n\n")
    }
}

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockedMacro.self,
    ]
}
