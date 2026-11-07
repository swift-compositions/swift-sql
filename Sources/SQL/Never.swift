public import ISO_9075_Foundation

extension Never: Table {
    public typealias QueryValue = Never

    public struct TableColumns: TableDefinition {
        public typealias QueryValue = Never

        public static var allColumns: [Column<Never>] { [] }

        public static var writableColumns: [Column<Never>] { [] }
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
