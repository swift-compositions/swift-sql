public import ISO_9075_Foundation

extension Schema.FTS5 {
    /// One or more FTS5 columns with a shared indexing policy.
    public struct Field<Root: Table>: Sendable {
        package let fragments: [ISO_9075.Fragment]

        package init(names: [String], unindexed: Bool) {
            self.fragments = names.map { name in
                var fragment: ISO_9075.Fragment = "\(quote: name)"
                if unindexed {
                    fragment.append(" UNINDEXED")
                }
                return fragment
            }
        }
    }
}

extension _TableColumnExpression {
    /// Excludes this field from the FTS5 full-text index while retaining its stored value.
    public func unindexed() -> Schema.FTS5.Field<Root> {
        Schema.FTS5.Field(names: _names, unindexed: true)
    }
}
