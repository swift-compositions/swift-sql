public import ISO_9075_Foundation

@dynamicMemberLookup
public protocol Table: QueryRepresentable, PartialSelectStatement, _SelectSource {
    associatedtype QueryValue = Self

    associatedtype From = Never

    associatedtype Draft = Never

    associatedtype TableColumns: TableDefinition<Self>

    associatedtype Selection: TableExpression<Self>

    associatedtype DefaultScope: SelectStatement<(), Self, ()>

    static var columns: TableColumns { get }

    static var tableName: String { get }

    static var tableAlias: String? { get }

    static var schemaName: String? { get }

    static var tableFragment: ISO_9075.Fragment { get }

    static var all: DefaultScope { get }
}

public protocol _Selection: Table {}

extension Table {
    public static var unscoped: Where<Self> {
        Where(scope: .unscoped)
    }

    @_disfavoredOverload
    public static var none: Where<Self> {
        Where(scope: .empty)
    }

    public static var tableAlias: String? {
        nil
    }

    public static var schemaName: String? {
        nil
    }

    public static var tableFragment: ISO_9075.Fragment {
        ISO_9075.Fragment(quote: tableName)
    }

    static var _allColumnsFragment: ISO_9075.Fragment {
        columns.queryFragment
    }

    public static subscript<Member: _TableColumnExpression>(
        dynamicMember keyPath: KeyPath<TableColumns, Member>
    ) -> Member {
        columns[keyPath: keyPath]
    }

    public var query: ISO_9075.Fragment {
        "SELECT \(TableColumns.allColumns.map { "\($0.render(self)) AS \(quote: $0.name)" }.joined(separator: ", "))"
    }

    public var queryFragment: ISO_9075.Fragment {
        _allFragments.joined(separator: ", ")
    }

    public var _allFragments: [ISO_9075.Fragment] {
        TableColumns.allColumns.map { $0.render(self) }
    }
}

extension Table where DefaultScope == Where<Self> {
    public static var all: DefaultScope {
        Where()
    }
}
