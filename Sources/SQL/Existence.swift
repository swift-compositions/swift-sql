public import ISO_9075_Foundation

/// A Boolean predicate testing whether a select returns any rows.
public struct Existence: Sendable {
    public let queryFragment: ISO_9075.Fragment

    package init(
        operator: ISO_9075.Fragment,
        select: ISO_9075.Fragment
    ) {
        self.queryFragment = "\(`operator`) \(select)"
    }
}

extension Existence: QueryExpression {
    public typealias QueryValue = Bool
}

extension QueryExpression where Self == Existence {
    /// Tests whether a typed select returns at least one row.
    ///
    /// The select may capture columns from an enclosing query to form a correlated subquery.
    ///
    /// - Parameter select: A closure producing the select to test.
    public static func exists<Select: PartialSelectStatement>(
        _ select: () -> Select
    ) -> Self {
        Self(operator: "EXISTS", select: select().queryFragment)
    }

    /// Tests whether a typed select returns no rows.
    ///
    /// The select may capture columns from an enclosing query to form a correlated subquery.
    ///
    /// - Parameter select: A closure producing the select to test.
    public static func notExists<Select: PartialSelectStatement>(
        _ select: () -> Select
    ) -> Self {
        Self(operator: "NOT EXISTS", select: select().queryFragment)
    }
}
