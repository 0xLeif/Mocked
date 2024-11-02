struct Variable {
    let name: String
    let type: String
    
    var declaration: String {
        "\(name): \(type)"
    }
}
