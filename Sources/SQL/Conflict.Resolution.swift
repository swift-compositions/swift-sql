public import ISO_9075_Foundation

extension Conflict {
    /// An algorithm for resolving a constraint violation.
    public enum Resolution: Sendable, CaseIterable {
        /// Rolls back the current transaction.
        case rollback

        /// Aborts the current statement and preserves earlier transaction changes.
        case abort

        /// Stops the current statement while preserving its earlier row changes.
        case fail

        /// Skips the row that violates a constraint.
        case ignore

        /// Removes the conflicting row before applying the current row change.
        case replace
    }
}

extension Conflict.Resolution: QueryExpression {
    public typealias QueryValue = Never

    public var queryFragment: ISO_9075.Fragment {
        switch self {
        case .rollback: "ROLLBACK"
        case .abort: "ABORT"
        case .fail: "FAIL"
        case .ignore: "IGNORE"
        case .replace: "REPLACE"
        }
    }
}
