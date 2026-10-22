public import ISO_9075_Foundation

extension Schema {
    /// A `CREATE TABLE` statement generated from an `@Table` declaration.
    public struct Definition<Root: Table>: Statement, Sendable {
        public typealias QueryValue = ()
        public typealias From = Never

        let ifNotExists: Bool
        let options: [Option]

        package init(ifNotExists: Bool, options: [Option]) {
            self.ifNotExists = ifNotExists
            self.options = options
        }

        public var query: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = "CREATE TABLE"
            if ifNotExists {
                query.append(" IF NOT EXISTS")
            }
            query.append(" ")
            if let schemaName = Root.schemaName {
                query.append("\(quote: schemaName).")
            }
            query.append("\(quote: Root.tableName)")
            let columns = Root.TableColumns.allColumns.map {
                Schema.Column($0, primaryKey: Root._primaryKeyNames.contains($0.name)).queryFragment
            }
            query.append(" (\(.newline)\(columns.joined(separator: ",\n").indented())\(.newline))")
            if !options.isEmpty {
                query.append(" \(options.map(\.queryFragment).joined(separator: ", "))")
            }
            return query
        }
    }
}

extension Schema.Create {
    /// Creates the table, deriving its columns, storage classes, nullability, and primary key from `Root`.
    public func table(
        ifNotExists: Bool = false,
        options: [Schema.Option] = []
    ) -> Schema.Definition<Root> {
        Schema.Definition(ifNotExists: ifNotExists, options: options)
    }
}
