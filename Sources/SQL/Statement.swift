public import ISO_9075_Foundation

public protocol Statement<QueryValue>: QueryExpression {
    associatedtype From

    associatedtype Joins = ()

    var query: ISO_9075.Fragment { get }

    var _hasUpsertParsingAmbiguity: Bool { get }
}

extension Statement {
    public var _hasUpsertParsingAmbiguity: Bool { false }

    public var queryFragment: ISO_9075.Fragment {
        "(\(.newline)\(query.indented())\(.newline))"
    }
}
