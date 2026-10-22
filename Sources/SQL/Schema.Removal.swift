public import ISO_9075_Foundation

extension Schema {
    /// A typed statement that drops a table or index.
    public struct Removal<Root: Table>: Statement, Sendable {
        public typealias QueryValue = ()
        public typealias From = Never

        let isIndex: Bool
        let name: String
        let ifExists: Bool

        package init(table: Root.Type, ifExists: Bool) {
            self.isIndex = false
            self.name = Root.tableName
            self.ifExists = ifExists
        }

        package init(index: String, ifExists: Bool) {
            self.isIndex = true
            self.name = index
            self.ifExists = ifExists
        }

        public var query: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = isIndex ? "DROP INDEX" : "DROP TABLE"
            if ifExists {
                query.append(" IF EXISTS")
            }
            query.append(" ")
            if let schemaName = Root.schemaName {
                query.append("\(quote: schemaName).")
            }
            query.append("\(quote: name)")
            return query
        }
    }
}

extension Schema.Drop {
    /// Drops the table represented by `Root`.
    public func table(ifExists: Bool = false) -> Schema.Removal<Root> {
        Schema.Removal(table: Root.self, ifExists: ifExists)
    }

    /// Drops a named index in the schema that owns `Root`.
    public func index(_ name: String, ifExists: Bool = false) -> Schema.Removal<Root> {
        Schema.Removal(index: name, ifExists: ifExists)
    }
}
