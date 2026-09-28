public import ISO_9075_Foundation

public protocol Collation: QueryExpression<Never> {
    var name: String { get }
}

extension Collation {
    public var queryFragment: ISO_9075.Fragment {
        "\(quote: name)"
    }
}

public struct NamedCollation: Collation, Sendable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public init(_ collation: some Collation) {
        self.name = collation.name
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable<String?> {
    public func collate(_ collation: some Collation) -> some QueryExpression<QueryValue> {
        SQLQueryExpression("\(self) COLLATE \(collation)")
    }
}
