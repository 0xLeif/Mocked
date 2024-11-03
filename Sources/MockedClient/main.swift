import Mocked

@Mocked
protocol ExampleProtocol: Sendable {
    associatedtype ItemType: Codable
    associatedtype ItemValue: Equatable

    var name: String { get set }
    var count: Int { get }
    var isEnabled: Bool { get set }

    func fetchItem(withID id: Int) async throws -> ItemType
    func saveItem(_ item: ItemType) throws -> Bool

    func processAllItems() async
    func reset()
    func optionalItem() -> ItemType?
}

let mock = MockedExampleProtocol<String, String>(name: "Leif", count: 0, isEnabled: true)
