public import ISO_9075_Foundation

extension PartialSelectStatement {
    public func union(
        all: Bool = false,
        _ other: some PartialSelectStatement<QueryValue>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: all ? .unionAll : .union, rhs: other)
    }

    public func intersect<F, J>(
        _ other: some SelectStatement<QueryValue, F, J>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: .intersect, rhs: other)
    }

    public func except<F, J>(
        _ other: some SelectStatement<QueryValue, F, J>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: .except, rhs: other)
    }
}

private struct CompoundSelect<QueryValue>: PartialSelectStatement {
    typealias From = Never
    typealias Joins = Never

    struct Operator {
        static var except: Self { Self(queryFragment: "EXCEPT") }
        static var intersect: Self { Self(queryFragment: "INTERSECT") }
        static var union: Self { Self(queryFragment: "UNION") }
        static var unionAll: Self { Self(queryFragment: "UNION ALL") }
        let queryFragment: ISO_9075.Fragment
    }

    let lhs: ISO_9075.Fragment
    let `operator`: ISO_9075.Fragment
    let rhs: ISO_9075.Fragment
    let hasUpsertParsingAmbiguity: Bool

    init(lhs: some PartialSelectStatement, operator: Operator, rhs: some PartialSelectStatement) {
        self.lhs = lhs.query
        self.operator = `operator`.queryFragment
        self.rhs = rhs.query
        hasUpsertParsingAmbiguity =
            self.rhs.isEmpty ? lhs._hasUpsertParsingAmbiguity : rhs._hasUpsertParsingAmbiguity
    }

    var query: ISO_9075.Fragment {
        guard !lhs.isEmpty else { return rhs }
        guard !rhs.isEmpty else { return lhs }
        return "\(lhs)\(.newlineOrSpace)\(`operator`.indented())\(.newlineOrSpace)\(rhs)"
    }
}

extension CompoundSelect {
    var _hasUpsertParsingAmbiguity: Bool { hasUpsertParsingAmbiguity }
}
