public import ISO_9075_Foundation

public struct NamedCollation: Collation, Sendable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public init(_ collation: some Collation) {
        self.name = collation.name
    }
}
