struct Function {
    let name: String
    let parameters: [Variable]
    let isSendable: Bool
    let isAsync: Bool
    let canThrow: Bool
    let returnType: String?

    var uniqueName: String {
        unique(name: name)
    }

    var overrideName: String {
        unique(name: "\(name)Override")
    }

    var closure: String {
        closure(name: uniqueName)
    }

    var overrideClosure: String {
        closure(name: overrideName)
    }

    private func closure(name: String) -> String {
        let parameters = parameters
            .map { parameter in
                "_ \(parameter.declaration)"
            }
            .joined(separator: ", ")

        let effectSignature: String = if canThrow && isAsync {
            "async throws"
        } else if canThrow {
            "throws"
        } else if isAsync {
            "async"
        } else {
            ""
        }

        return if effectSignature.isEmpty {
            "\(name): (\(isSendable ? "@Sendable " : "")(\(parameters)) -> \(returnType ?? "Void"))?"
        } else {
            "\(name): (\(isSendable ? "@Sendable " : "")(\(parameters)) \(effectSignature) -> \(returnType ?? "Void"))?"
        }
    }

    private func unique(name: String) -> String {
        let effectSignature: String = if canThrow && isAsync {
            "AsyncThrows"
        } else if canThrow {
            "Throws"
        } else if isAsync {
            "Async"
        } else {
            ""
        }

        let parameters = parameters
            .map(\.name.capitalized)
            .joined(separator: "")

        return "\(name)\(effectSignature)\(parameters)"
    }
}
