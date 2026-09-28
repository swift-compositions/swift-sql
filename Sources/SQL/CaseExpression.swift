public import ISO_9075_Foundation

public struct Case<Base, QueryValue: _OptionalPromotable> {
    var base: ISO_9075.Fragment?

    public init(
        _ base: some QueryExpression<Base>
    ) {
        self.base = base.queryFragment
    }

    public init() where Base == Bool {}

    public func when(
        _ condition: some QueryExpression<Base>,
        then expression: some QueryExpression<QueryValue>
    ) -> Cases<Base, QueryValue?> {
        Cases(
            base: base,
            cases: [
                When(predicate: condition.queryFragment, expression: expression.queryFragment)
                    .queryFragment
            ]
        )
    }

    public func when(
        _ condition: some QueryExpression<Base>,
        then expression: some QueryExpression<QueryValue._Optionalized>
    ) -> Cases<Base, QueryValue._Optionalized> {
        Cases(
            base: base,
            cases: [
                When(predicate: condition.queryFragment, expression: expression.queryFragment)
                    .queryFragment
            ]
        )
    }
}

public struct Cases<Base, QueryValue: _OptionalProtocol>: QueryExpression {
    var base: ISO_9075.Fragment?
    var cases: [ISO_9075.Fragment]

    public func when(
        _ condition: some QueryExpression<Base>,
        then expression: some QueryExpression<QueryValue>
    ) -> Cases {
        var cases = self
        cases.cases.append(
            When(predicate: condition.queryFragment, expression: expression.queryFragment)
                .queryFragment
        )
        return cases
    }

    public func when(
        _ condition: some QueryExpression<Base>,
        then expression: some QueryExpression<QueryValue.Wrapped>
    ) -> Cases {
        var cases = self
        cases.cases.append(
            When(predicate: condition.queryFragment, expression: expression.queryFragment)
                .queryFragment
        )
        return cases
    }

    public func `else`(
        _ expression: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<QueryValue.Wrapped> {
        var cases = self
        cases.cases.append("ELSE \(expression)")
        return SQLQueryExpression(cases.queryFragment)
    }

    public var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "CASE"
        if let base {
            query.append(" \(base)")
        }
        query.append(" \(cases.joined(separator: " ")) END")
        return query
    }
}

private struct When: QueryExpression {
    typealias QueryValue = Never

    let predicate: ISO_9075.Fragment
    let expression: ISO_9075.Fragment

    public var queryFragment: ISO_9075.Fragment {
        "WHEN \(predicate) THEN \(expression)"
    }
}
