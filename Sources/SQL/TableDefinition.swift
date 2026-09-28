public import ISO_9075_Foundation

@dynamicMemberLookup
public protocol TableDefinition<QueryValue>: QueryExpression where QueryValue: Table {
    static var allColumns: [Column<QueryValue>] { get }

    static var writableColumns: [Column<QueryValue>] { get }
}

extension TableDefinition {
    public var queryFragment: ISO_9075.Fragment {
        Self.allColumns.map(\.queryFragment).joined(separator: ", ")
    }

    @_disfavoredOverload
    public subscript<Member>(
        dynamicMember keyPath: KeyPath<Self, Member>
    ) -> Member {
        self[keyPath: keyPath]
    }

    public static var _columnWidth: Int {
        QueryValue._columnWidth
    }

    public var _allFragments: [ISO_9075.Fragment] {
        Self.allColumns.map(\.queryFragment)
    }
}
