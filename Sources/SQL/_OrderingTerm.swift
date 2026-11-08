public import ISO_9075_Foundation
public import Order

public struct _OrderingTerm<Value>: QueryExpression, Sendable {
    public var baseQueryFragment: ISO_9075.Fragment

    public let direction: Order.Direction
    public let nullOrdering: NullOrdering?

    init(base: some QueryExpression<Value>, direction: Order.Direction, nullOrdering: NullOrdering?) {
        self.baseQueryFragment = base.queryFragment
        self.direction = direction
        self.nullOrdering = nullOrdering
    }
}
