public import ISO_9075_Foundation

extension Schema {
    /// An option appended to a table definition.
    public enum Option: Hashable, Sendable {
        /// Enforces SQLite strict typing for the table.
        case strict

        /// Creates a SQLite table without its implicit row identifier.
        case withoutRowID
    }
}

extension Schema.Option: QueryExpression {
    public typealias QueryValue = ()

    public var queryFragment: ISO_9075.Fragment {
        switch self {
        case .strict: "STRICT"
        case .withoutRowID: "WITHOUT ROWID"
        }
    }
}
