public import ISO_9075_Foundation

public protocol Collation: QueryExpression<Never> {
    var name: String { get }
}

extension Collation {
    public var queryFragment: ISO_9075.Fragment {
        "\(quote: name)"
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable<String?> {
    public func collate(_ collation: some Collation) -> some QueryExpression<QueryValue> {
        SQLQueryExpression("\(self) COLLATE \(collation)")
    }
}
