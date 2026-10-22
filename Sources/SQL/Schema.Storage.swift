public import ISO_9075_Foundation

extension Schema {
    /// A storage class used by a database column.
    public enum Storage: String, Hashable, Sendable {
        /// A signed integer value.
        case integer = "INTEGER"

        /// A floating-point value.
        case real = "REAL"

        /// A character value.
        case text = "TEXT"

        /// A binary value.
        case blob = "BLOB"
    }
}

extension Schema.Storage: QueryExpression {
    public typealias QueryValue = ()

    public var queryFragment: ISO_9075.Fragment {
        ISO_9075.Fragment(rawValue)
    }
}
