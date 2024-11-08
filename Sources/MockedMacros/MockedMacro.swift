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
            context.diagnose(
                .init(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        "MockedMacro can only be applied to protocols"
                    )
                )
            )
            return []
        }

        // Check for access level argument (e.g., @Mocked(.public))
        var accessLevel: String = "internal"

        if case let .argumentList(argumentList) = node.arguments {
            // Process each argument in the list
            for argument in argumentList {
                let preferredAccessLevel = "\(argument.expression)"

                if preferredAccessLevel.contains("public") {
                    accessLevel = "public"
                } else if preferredAccessLevel.contains("fileprivate") {
                    accessLevel = "fileprivate"
                } else if preferredAccessLevel.contains("private") {
                    accessLevel = "private"
                } else if preferredAccessLevel.contains("open") {
                    accessLevel = "open"
                } else if preferredAccessLevel.contains("package") {
                    accessLevel = "package"
                } else if preferredAccessLevel.contains("internal") {
                    accessLevel = "internal"
                } else {
                    context.diagnose(
                        .init(
                            node: node,
                            message: MacroExpansionErrorMessage(
                                "Invalid access level for @Mocked: \(preferredAccessLevel)"
                            )
                        )
                    )
                    return []
                }
            }
        }

        let initAccessLevel = switch accessLevel {
        case "public":  "public"
        case "open":    "open"
        case "package": "package"
        default:        "internal"
        }

        let mockClassName = "Mocked\(protocolDecl.name.text)"

        let members = protocolDecl.memberBlock.members

        // Variables

        let variables: [Variable] = variableBuilder(members: members)

        let variablesDefinitions: String = variableDefinitions(variables: variables, accessLevel: accessLevel)
        let variablesInitDefinitions: String = variablesInitDefinitions(variables: variables)
        let variablesInitAssignments: String = variablesInitAssignments(variables: variables)

        // Functions

        let functions: [Function] = functionBuilder(protocolDecl: protocolDecl, members: members)

        let functionVariableDefinitions: String = functionVariableDefinitions(functions: functions)
        let functionVariableInitDefinitions: String = functionVariableInitDefinitions(functions: functions)
        let functionVariableInitAssignments: String = functionVariableInitAssignments(functions: functions)
        let functionImplementations: String = functionImplementations(functions: functions, accessLevel: accessLevel)

        // Check if the protocol conforms to AnyObject
        let requiresClassConformance = protocolDecl.inheritanceClause?.inheritedTypes.contains(
            where: { $0.type.description.trimmingCharacters(in: .whitespacesAndNewlines) == "AnyObject" }
        ) ?? false

        let objectType: String = requiresClassConformance ? "class" : "struct"

        // Check for associated types in the protocol
        var associatedTypes: [String] = []

        for member in protocolDecl.memberBlock.members {
            if let associatedTypeDecl = member.decl.as(AssociatedTypeDeclSyntax.self) {
                let name = associatedTypeDecl.name.text
                let constraint = associatedTypeDecl.inheritanceClause?.description.trimmingCharacters(in: .whitespacesAndNewlines)

                if let constraint {
                    associatedTypes.append("\(name)\(constraint)")
                } else {
                    associatedTypes.append(name)
                }
            }
        }

        // Construct generic type parameters if there are associated types
        let genericValues = if associatedTypes.isEmpty {
            ""
        } else {
            "<" + associatedTypes.joined(separator: ", ") + ">"
        }

        return [
            """
            /// Mocked version of \(raw: protocolDecl.name.text)
            \(raw: accessLevel) \(raw: objectType) \(raw: mockClassName)\(raw: genericValues): \(raw: protocolDecl.name.text) {
                // MARK: - \(raw: mockClassName) Variables
            
                \(raw: variablesDefinitions)
            
                // MARK: - \(raw: mockClassName) Function Overrides
            
                \(raw: functionVariableDefinitions)
            
                // MARK: - \(raw: mockClassName) init
            
                \(raw: initAccessLevel) init(
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
        variables: [Variable],
        accessLevel: String
    ) -> String {
        variables
            .map { variable in
                if accessLevel.contains("public") {
                    "public var \(variable.declaration)"
                } else if accessLevel.contains("package") {
                    "package var \(variable.declaration)"
                } else {
                    "var \(variable.declaration)"
                }
            }
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
        functions: [Function],
        accessLevel: String
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

            let accessLevel: String = if accessLevel.contains("public") {
                "public"
            } else if accessLevel.contains("package") {
                "package"
            } else {
                "internal"
            }

            if parameters.isEmpty {
                return """
                    \(accessLevel) func \(function.name)() \(effectSignature)-> \(function.returnType ?? "Void") {
                        guard let \(function.overrideName) else {
                            fatalError("Mocked \(function.closure) was not implemented!")
                        }
                    
                        return \(callSignature)\(function.overrideName)()
                    }
                    """
            } else {
                return """
                    \(accessLevel) func \(function.name)(
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
