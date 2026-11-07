public import ISO_9075_Foundation

public struct SQLQueryExpression<QueryValue>: Sendable, Statement {
    public typealias From = Never

    public let queryFragment: ISO_9075.Fragment

    public var query: ISO_9075.Fragment { queryFragment }

    public init(
        _ queryFragment: ISO_9075.Fragment,
        as queryValueType: QueryValue.Type = QueryValue.self
    ) {
        self.queryFragment = queryFragment
    }

    public init(_ queryFragment: ISO_9075.Fragment) where QueryValue == () {
        self.queryFragment = queryFragment
    }

    @_disfavoredOverload
    public init(_ expression: some QueryExpression<QueryValue>) {
        self.queryFragment = expression.queryFragment
    }

    public init(_ statement: some Statement<QueryValue>) {
        self.queryFragment = statement.query
    }
}
