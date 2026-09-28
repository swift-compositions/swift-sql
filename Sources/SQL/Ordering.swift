public import ISO_9075_Foundation
public import Order

extension QueryExpression where QueryValue: QueryBindable {
    public func asc(nulls nullOrdering: NullOrdering? = nil) -> _OrderingTerm<QueryValue> {
        _OrderingTerm(base: self, direction: .ascending, nullOrdering: nullOrdering)
    }

    public func desc(nulls nullOrdering: NullOrdering? = nil) -> _OrderingTerm<QueryValue> {
        _OrderingTerm(base: self, direction: .descending, nullOrdering: nullOrdering)
    }

    public func ordered(_ direction: Order.Direction, nulls nullOrdering: NullOrdering? = nil) -> _OrderingTerm<QueryValue> {
        _OrderingTerm(base: self, direction: direction, nullOrdering: nullOrdering)
    }
}

public enum NullOrdering: Sendable, Hashable, CaseIterable {
    case first

    case last
}

public struct _OrderingTerm<Value>: QueryExpression, Sendable {
    public typealias QueryValue = Never

    public var baseQueryFragment: ISO_9075.Fragment

    public let direction: Order.Direction
    public let nullOrdering: NullOrdering?

    init(base: some QueryExpression<Value>, direction: Order.Direction, nullOrdering: NullOrdering?) {
        self.baseQueryFragment = base.queryFragment
        self.direction = direction
        self.nullOrdering = nullOrdering
    }

    public var base: some QueryExpression<Value> & Sendable {
        SQLQueryExpression(baseQueryFragment)
    }

    public var queryFragment: ISO_9075.Fragment {
        let direction: ISO_9075.Fragment = switch direction {
        case .ascending: "ASC"
        case .descending: "DESC"
        }
        let nulls: ISO_9075.Fragment = switch nullOrdering {
        case .first: " NULLS FIRST"
        case .last: " NULLS LAST"
        case nil: ""
        }
        return "\(baseQueryFragment) \(direction)\(nulls)"
    }
}
