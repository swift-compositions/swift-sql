public import ISO_9075_Foundation

public struct BindQueryExpression<QueryValue: QueryRepresentable & QueryExpression>: QueryExpression
{
    public let base: QueryValue

    public init(
        _ queryOutput: QueryValue.QueryOutput,
        as queryValueType: QueryValue.Type = QueryValue.self
    ) {
        self.base = QueryValue(queryOutput: queryOutput)
    }

    public var queryFragment: ISO_9075.Fragment {
        base.queryFragment
    }
}
