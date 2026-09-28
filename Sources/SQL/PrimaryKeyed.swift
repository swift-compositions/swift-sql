public import ISO_9075_Foundation

public protocol PrimaryKeyedTable<PrimaryKey>: Table
where
    TableColumns: PrimaryKeyedTableDefinition<PrimaryKey>,
    Draft: TableDraft,
    Draft.SourceTable == Self
{
    associatedtype PrimaryKey: QueryRepresentable & QueryExpression
    where PrimaryKey.QueryValue == PrimaryKey
}

public protocol TableDraft: Table {
    associatedtype SourceTable: Table where SourceTable.Draft == Self

    init(_ source: SourceTable)
}

extension TableDraft where SourceTable: PrimaryKeyedTable {
    public typealias PrimaryKey = SourceTable.PrimaryKey
}

extension TableDraft {
    public static subscript(
        dynamicMember keyPath: KeyPath<SourceTable.Type, some Statement<SourceTable>>
    ) -> some Statement<Self> {
        SQLQueryExpression("\(SourceTable.self[keyPath: keyPath])")
    }

    public static subscript(
        dynamicMember keyPath: KeyPath<SourceTable.Type, some SelectStatementOf<SourceTable>>
    ) -> SelectOf<Self> {
        unsafeBitCast(SourceTable.self[keyPath: keyPath].asSelect(), to: SelectOf<Self>.self)
    }

    public static var all: SelectOf<Self> {
        unsafeBitCast(SourceTable.all.asSelect(), to: SelectOf<Self>.self)
    }

    public static var schemaName: String? { SourceTable.schemaName }

    public static var tableName: String { SourceTable.tableName }
}

public protocol PrimaryKeyedTableDefinition<PrimaryKey>: TableDefinition
where QueryValue: PrimaryKeyedTable {
    associatedtype PrimaryKey: QueryRepresentable & QueryExpression
    where PrimaryKey.QueryValue == PrimaryKey

    associatedtype PrimaryColumn: _TableColumnExpression<QueryValue, PrimaryKey>

    var primaryKey: PrimaryColumn { get }
}

extension TableDefinition where QueryValue: TableDraft {
    public subscript<Member>(
        dynamicMember keyPath: KeyPath<QueryValue.SourceTable.TableColumns, Member>
    ) -> Member {
        QueryValue.SourceTable.columns[keyPath: keyPath]
    }
}

extension PrimaryKeyedTableDefinition where PrimaryColumn: TableColumnExpression {
    public func count(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Int> {
        primaryKey.count(distinct: isDistinct, filter: filter)
    }
}

extension PrimaryKeyedTable {
    public static func find(
        _ primaryKey: some QueryExpression<PrimaryKey>
    ) -> Where<Self> {
        find([primaryKey])
    }

    public static func find(
        _ primaryKeys: some Sequence<some QueryExpression<PrimaryKey>>
    ) -> Where<Self> {
        Self.where { $0.primaryKey.in(primaryKeys) }
    }

    public var primaryKey: PrimaryKey.QueryOutput {
        self[keyPath: Self.columns.primaryKey.keyPath]
    }
}

extension TableDraft where SourceTable: PrimaryKeyedTable {
    public static func find(
        _ primaryKey: some QueryExpression<SourceTable.PrimaryKey>
    ) -> Where<Self> {
        find([primaryKey])
    }

    public static func find(
        _ primaryKeys: some Sequence<some QueryExpression<SourceTable.PrimaryKey>>
    ) -> Where<Self> {
        Self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Where where From: PrimaryKeyedTable {
    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Where where From: TableDraft, From.SourceTable: PrimaryKeyedTable {
    public func find(
        _ primaryKey: some QueryExpression<From.SourceTable.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.SourceTable.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Select where From: PrimaryKeyedTable {
    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        and(From.find(primaryKey))
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        and(From.find(primaryKeys))
    }
}

extension Select where From: TableDraft, From.SourceTable: PrimaryKeyedTable {
    public func find(
        _ primaryKey: some QueryExpression<From.SourceTable.PrimaryKey>
    ) -> Self {
        and(From.find(primaryKey))
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.SourceTable.PrimaryKey>>
    ) -> Self {
        and(From.find(primaryKeys))
    }
}

extension Update where From: PrimaryKeyedTable {
    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Update where From: TableDraft, From.SourceTable: PrimaryKeyedTable {
    public func find(
        _ primaryKey: some QueryExpression<From.SourceTable.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.SourceTable.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Delete where From: PrimaryKeyedTable {
    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}

extension Delete where From: TableDraft, From.SourceTable: PrimaryKeyedTable {
    public func find(
        _ primaryKey: some QueryExpression<From.SourceTable.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Sequence<some QueryExpression<From.SourceTable.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey.in(primaryKeys) }
    }
}
