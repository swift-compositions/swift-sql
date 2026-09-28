public import ISO_9075_Foundation

extension Never: Table {
    public struct TableColumns: TableDefinition {
        public typealias QueryValue = Never

        public static var allColumns: [any TableColumnExpression] { [] }

        public static var writableColumns: [any WritableTableColumnExpression] { [] }
    }

    public struct Selection: TableExpression {
        public typealias QueryValue = Never

        public var allColumns: [ISO_9075.Fragment] { [] }
    }

    public static var columns: TableColumns {
        TableColumns()
    }

    public static let tableName = "nevers"

    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        throw .typeMismatch(expected: "Never")
    }
}

extension Never: _Selection {}
