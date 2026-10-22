// swift-format-ignore-file: AmbiguousTrailingClosureOverload
// REASON: the index terms and partial-index predicate both use result-builder closures.

public import ISO_9075_Foundation

extension Schema {
    /// A typed `CREATE INDEX` statement.
    public struct Index<Root: Table>: Statement, Sendable {
        public typealias QueryValue = ()
        public typealias From = Never

        let name: String
        let isUnique: Bool
        let ifNotExists: Bool
        let terms: [ISO_9075.Fragment]
        var predicate: [ISO_9075.Fragment]

        package init(
            name: String,
            isUnique: Bool,
            ifNotExists: Bool,
            terms: [ISO_9075.Fragment],
            predicate: [ISO_9075.Fragment] = []
        ) {
            self.name = name
            self.isUnique = isUnique
            self.ifNotExists = ifNotExists
            self.terms = terms
            self.predicate = predicate
        }

        /// Restricts this index to rows matching a typed predicate.
        public func `where`(
            @QueryFragmentBuilder<Bool>
            _ predicate: (Root.TableColumns) -> [ISO_9075.Fragment]
        ) -> Self {
            var index = self
            index.predicate = $_isDefiningSchema.withValue(true) {
                predicate(Root.columns)
            }
            return index
        }

        /// Drops this index.
        public func drop(ifExists: Bool = false) -> Schema.Removal<Root> {
            Schema.Removal(index: name, ifExists: ifExists)
        }

        public var query: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = "CREATE"
            if isUnique {
                query.append(" UNIQUE")
            }
            query.append(" INDEX")
            if ifNotExists {
                query.append(" IF NOT EXISTS")
            }
            query.append(" ")
            if let schemaName = Root.schemaName {
                query.append("\(quote: schemaName).")
            }
            query.append("\(quote: name) ON \(quote: Root.tableName)")
            query.append(" (\(terms.joined(separator: ", ")))")
            if !predicate.isEmpty {
                let predicate: ISO_9075.Fragment =
                    predicate
                    .map { "(\($0))" }
                    .joined(separator: " AND ")
                query.append(" WHERE \(predicate)")
            }
            return query
        }
    }
}

extension Schema.Create {
    /// Creates an index from typed columns or expressions of `Root`.
    public func index(
        _ name: String,
        unique: Bool = false,
        ifNotExists: Bool = false,
        @QueryFragmentBuilder<()> _ terms: (Root.TableColumns) -> [ISO_9075.Fragment]
    ) -> Schema.Index<Root> {
        Schema.Index(
            name: name,
            isUnique: unique,
            ifNotExists: ifNotExists,
            terms: $_isDefiningSchema.withValue(true) { terms(Root.columns) }
        )
    }
}
