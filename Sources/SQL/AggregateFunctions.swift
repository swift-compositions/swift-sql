public import ISO_9075_Foundation

extension QueryExpression where QueryValue: QueryBindable {
    public func count(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Int> {
        AggregateFunctionExpression(
            "count",
            isDistinct: isDistinct,
            [queryFragment],
            filter: filter?.queryFragment
        )
    }
}

extension QueryExpression where QueryValue: QueryBindable & _OptionalPromotable {
    public func max(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<QueryValue._Optionalized.Wrapped?> {
        AggregateFunctionExpression("max", [queryFragment], filter: filter?.queryFragment)
    }

    public func min(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<QueryValue._Optionalized.Wrapped?> {
        AggregateFunctionExpression("min", [queryFragment], filter: filter?.queryFragment)
    }
}

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped: Numeric {
    public func avg(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        AggregateFunctionExpression(
            "avg",
            isDistinct: isDistinct,
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func sum(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> SQLQueryExpression<QueryValue._Optionalized> {
        SQLQueryExpression(
            AggregateFunctionExpression<QueryValue._Optionalized>(
                "sum",
                isDistinct: isDistinct,
                [queryFragment],
                filter: filter?.queryFragment
            )
            .queryFragment
        )
    }

}

extension QueryExpression where Self == AggregateFunctionExpression<Int> {
    public static func count(
        filter: (any QueryExpression<Bool>)? = nil
    ) -> Self {
        AggregateFunctionExpression("count", ["*"], filter: filter?.queryFragment)
    }
}

public struct AggregateFunctionExpression<QueryValue>: QueryExpression, Sendable {
    var name: ISO_9075.Fragment
    var isDistinct: Bool
    var arguments: [ISO_9075.Fragment]
    var order: ISO_9075.Fragment?
    var filter: ISO_9075.Fragment?

    public init<each Argument: QueryExpression>(
        _ name: String,
        distinct isDistinct: Bool = false,
        _ arguments: repeat each Argument,
        order: (some QueryExpression)? = Bool?.none,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) {
        self.init(
            ISO_9075.Fragment(quote: name),
            isDistinct: isDistinct,
            Array(repeat each arguments),
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }

    package init(
        _ name: ISO_9075.Fragment,
        isDistinct: Bool = false,
        _ arguments: [ISO_9075.Fragment] = [],
        order: ISO_9075.Fragment? = nil,
        filter: ISO_9075.Fragment? = nil
    ) {
        self.name = name
        self.isDistinct = isDistinct
        self.arguments = arguments
        self.order = order
        self.filter = filter
    }

    public var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "\(name)("
        if isDistinct {
            query.append("DISTINCT ")
        }
        query.append(arguments.joined(separator: ", "))
        if let order {
            query.append(" ORDER BY \(order)")
        }
        query.append(")")
        if let filter {
            query.append(" FILTER (WHERE \(filter))")
        }
        return query
    }
}
