public import ISO_9075_Foundation

extension Schema {
    /// A column definition derived from a table column.
    public struct Column<Root: Table>: QueryExpression, Sendable {
        public typealias QueryValue = ()

        /// The delimited identifier's unquoted value.
        public let name: String

        /// The column's database storage class.
        public let storage: Storage

        /// Whether the column accepts `NULL`.
        public let isNullable: Bool

        /// Whether the column is the table's primary key.
        public let isPrimaryKey: Bool

        package init(_ column: SQL.Column<Root>, primaryKey: Bool) {
            self.name = column.name
            self.storage = column.storage
            self.isNullable = column.isNullable
            self.isPrimaryKey = primaryKey
        }

        package init<Definition: TableColumnExpression>(
            _ column: Definition,
            primaryKey: Bool
        ) where Definition.Root == Root {
            self.name = column.name
            self.storage = Definition.Value.storage
            self.isNullable = Definition.Value.isNullable
            self.isPrimaryKey = primaryKey
        }

        public var queryFragment: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = "\(quote: name) \(storage)"
            if isPrimaryKey {
                query.append(" PRIMARY KEY")
            }
            if !isNullable {
                query.append(" NOT NULL")
            }
            return query
        }
    }
}
