public import ISO_9075_Foundation

public protocol TableExpression<QueryValue>: QueryExpression where QueryValue: Table {
    var allColumns: [any QueryExpression] { get }
}

extension TableExpression {
    public var queryFragment: ISO_9075.Fragment {
        if _isSelecting {
            return zip(allColumns, QueryValue.TableColumns.allColumns)
                .map { "\($0) AS \(quote: $1.name)" }
                .joined(separator: ", ")
        } else {
            return allColumns.map(\.queryFragment).joined(separator: ", ")
        }
    }

    public static var _columnWidth: Int {
        QueryValue._columnWidth
    }

    public var _allColumns: [any QueryExpression] {
        allColumns
    }
}

extension Table {
    public typealias Columns = Selection
}
