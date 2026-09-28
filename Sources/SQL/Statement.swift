public import ISO_9075_Foundation

public protocol Statement<QueryValue>: QueryExpression {
    associatedtype From

    associatedtype Joins = ()

    var query: ISO_9075.Fragment { get }
}

extension Statement {
    public var queryFragment: ISO_9075.Fragment {
        "(\(.newline)\(query.indented())\(.newline))"
    }
}
