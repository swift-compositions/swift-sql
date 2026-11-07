import ISO_9075_Foundation

public protocol PrimaryKeyedTableDefinition<PrimaryKey>: TableDefinition
where QueryValue: PrimaryKeyedTable {
    associatedtype PrimaryKey: QueryRepresentable & QueryExpression
    where PrimaryKey.QueryValue == PrimaryKey

    associatedtype PrimaryColumn: _TableColumnExpression<QueryValue, PrimaryKey>

    var primaryKey: PrimaryColumn { get }
}
