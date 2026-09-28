public import ISO_9075_Foundation

extension QueryExpression where QueryValue: QueryBindable {
    public func asc(nulls nullOrdering: NullOrdering? = nil) -> _OrderingTerm<QueryValue> {
        _OrderingTerm(base: self, direction: .asc, nullOrdering: nullOrdering)
    }

    public func desc(nulls nullOrdering: NullOrdering? = nil) -> _OrderingTerm<QueryValue> {
        _OrderingTerm(base: self, direction: .desc, nullOrdering: nullOrdering)
    }

}

public struct NullOrdering: RawRepresentable, Sendable {
    public static let first = Self(rawValue: "FIRST")

    public static let last = Self(rawValue: "LAST")

    public let rawValue: ISO_9075.Fragment

    public init(rawValue: ISO_9075.Fragment) {
        self.rawValue = rawValue
    }
}

public struct _OrderingTerm<Value>: QueryExpression, Sendable {
    public typealias QueryValue = Never

    struct Direction {
        static var asc: Self { Self(queryFragment: "ASC") }
        static var desc: Self { Self(queryFragment: "DESC") }
        let queryFragment: ISO_9075.Fragment
    }

    public var baseQueryFragment: ISO_9075.Fragment

    let direction: Direction
    let nullOrdering: NullOrdering?

    init(base: some QueryExpression<Value>, direction: Direction, nullOrdering: NullOrdering?) {
        self.baseQueryFragment = base.queryFragment
        self.direction = direction
        self.nullOrdering = nullOrdering
    }

    public var base: some QueryExpression<Value> & Sendable {
        SQLQueryExpression(baseQueryFragment)
    }

    public var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "\(baseQueryFragment) \(direction.queryFragment)"
        if let nullOrdering {
            query.append(" NULLS \(nullOrdering.rawValue)")
        }
        return query
    }
}
