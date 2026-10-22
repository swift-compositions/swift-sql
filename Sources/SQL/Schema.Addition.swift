public import ISO_9075_Foundation

extension Schema {
    /// A typed `ALTER TABLE ADD COLUMN` statement.
    public struct Addition<Root: Table>: Statement, Sendable {
        public typealias QueryValue = ()
        public typealias From = Never

        let column: Schema.Column<Root>

        package init(column: Schema.Column<Root>) {
            self.column = column
        }

        public var query: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = "ALTER TABLE "
            if let schemaName = Root.schemaName {
                query.append("\(quote: schemaName).")
            }
            query.append("\(quote: Root.tableName) ADD COLUMN \(column)")
            return query
        }
    }
}

extension Schema.Alter {
    /// Adds a stored column selected from the current `@Table` declaration.
    public func add<Value: QueryRepresentable & QueryBindable>(
        _ column: KeyPath<Root.TableColumns, TableColumn<Root, Value>>
    ) -> Schema.Addition<Root> {
        let definition = Root.columns[keyPath: column]
        return Schema.Addition(
            column: Schema.Column(
                definition,
                primaryKey: Root._primaryKeyNames.contains(definition.name)
            )
        )
    }

    /// Adds a generated column selected from the current `@Table` declaration.
    public func add<Value: QueryRepresentable & QueryBindable>(
        _ column: KeyPath<Root.TableColumns, GeneratedColumn<Root, Value>>
    ) -> Schema.Addition<Root> {
        let definition = Root.columns[keyPath: column]
        return Schema.Addition(
            column: Schema.Column(
                definition,
                primaryKey: Root._primaryKeyNames.contains(definition.name)
            )
        )
    }
}
