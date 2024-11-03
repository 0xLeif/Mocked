struct Variable {
    let firstName: String
    let secondName: String?
    let type: String

    var name: String {
        guard
            let secondName,
            firstName == "_"
        else {
            return firstName
        }

        return secondName
    }

    var parameterName: String {
        guard let secondName else {
            return firstName
        }

        return "\(firstName) \(secondName)"
    }

    var usageName: String {
        guard let secondName else {
            return firstName
        }
        
        return secondName
    }

    var declaration: String {
        "\(name): \(type)"
    }
}
