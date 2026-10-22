public import ISO_9075_Foundation

/// The implementation protocol exposed as ``FTS5/Table``.
public protocol _FTS5Table: Table {}

extension FTS5 {
    /// A typed table backed by SQLite's FTS5 virtual-table module.
    ///
    /// Apply this conformance to a `@Table` declaration to create, populate, delete from, and
    /// search the virtual table without string-literal SQL.
    public typealias Table = _FTS5Table
}

extension _FTS5Table {
    /// Creates the FTS5 virtual table.
    ///
    /// Every writable table column becomes an FTS5 column. Key paths in `unindexed` are emitted
    /// with the `UNINDEXED` column option.
    ///
    /// - Parameters:
    ///   - ifNotExists: Whether to suppress an error when the table already exists.
    ///   - unindexed: Columns whose values are stored but excluded from the full-text index.
    ///   - tokenizer: The tokenizer and its typed options, or `nil` for SQLite's default.
    public static func create(
        ifNotExists: Bool = false,
        unindexed: [PartialKeyPath<Self>] = [],
        tokenizer: FTS5.Tokenizer? = nil
    ) -> SQLQueryExpression<()> {
        create(
            ifNotExists: ifNotExists,
            unindexed: unindexed,
            tokenizer: tokenizer,
            content: nil,
            contentRowID: nil
        )
    }

    /// Creates an external-content FTS5 virtual table.
    ///
    /// - Parameters:
    ///   - ifNotExists: Whether to suppress an error when the table already exists.
    ///   - unindexed: Columns whose values are stored but excluded from the full-text index.
    ///   - tokenizer: The tokenizer and its typed options, or `nil` for SQLite's default.
    ///   - content: The table from which FTS5 reads column values.
    public static func create<Content: Table>(
        ifNotExists: Bool = false,
        unindexed: [PartialKeyPath<Self>] = [],
        tokenizer: FTS5.Tokenizer? = nil,
        content: Content.Type
    ) -> SQLQueryExpression<()> {
        create(
            ifNotExists: ifNotExists,
            unindexed: unindexed,
            tokenizer: tokenizer,
            content: Content.tableName,
            contentRowID: nil
        )
    }

    /// Creates an external-content FTS5 virtual table with an explicit content rowid column.
    ///
    /// - Parameters:
    ///   - ifNotExists: Whether to suppress an error when the table already exists.
    ///   - unindexed: Columns whose values are stored but excluded from the full-text index.
    ///   - tokenizer: The tokenizer and its typed options, or `nil` for SQLite's default.
    ///   - content: The table from which FTS5 reads column values.
    ///   - rowid: The content-table column corresponding to the FTS5 rowid.
    public static func create<Content: Table, RowID>(
        ifNotExists: Bool = false,
        unindexed: [PartialKeyPath<Self>] = [],
        tokenizer: FTS5.Tokenizer? = nil,
        content: Content.Type,
        rowid: KeyPath<Content, RowID>
    ) -> SQLQueryExpression<()>
    where RowID: QueryBindable {
        guard let column = Content.TableColumns.allColumns.first(where: { $0.keyPath == rowid })
        else {
            preconditionFailure("Key path is not a column of \(Content.self): \(rowid)")
        }
        return create(
            ifNotExists: ifNotExists,
            unindexed: unindexed,
            tokenizer: tokenizer,
            content: Content.tableName,
            contentRowID: column.name
        )
    }

    /// Inserts a typed row at an explicit FTS5 rowid.
    ///
    /// Both the rowid and every row value are rendered as bound query values.
    public static func insert(
        rowid: some QueryExpression<Int>,
        _ row: Self
    ) -> InsertOf<Self> {
        _insert(
            columnNames: ["rowid"] + TableColumns.writableColumns.map(\.name),
            rows: [
                [rowid.queryFragment]
                    + TableColumns.writableColumns.map { $0.rendering(row, primaryKeys: []) }
            ]
        )
    }

    /// Deletes the FTS5 row having the given rowid.
    public static func delete(
        rowid: some QueryExpression<Int>
    ) -> DeleteOf<Self> {
        delete().where { $0.rowid.eq(rowid) }
    }

    private static func create(
        ifNotExists: Bool,
        unindexed: [PartialKeyPath<Self>],
        tokenizer: FTS5.Tokenizer?,
        content: String?,
        contentRowID: String?
    ) -> SQLQueryExpression<()> {
        let unindexed = Set(
            unindexed.map { keyPath in
                guard let column = TableColumns.allColumns.first(where: { $0.keyPath == keyPath })
                else {
                    preconditionFailure("Key path is not a column of \(Self.self): \(keyPath)")
                }
                return column.name
            }
        )
        var arguments = TableColumns.writableColumns.map { column -> ISO_9075.Fragment in
            var argument: ISO_9075.Fragment = "\(quote: column.name)"
            if unindexed.contains(column.name) {
                argument.append(" UNINDEXED")
            }
            return argument
        }
        if let tokenizer {
            arguments.append("tokenize = \(text: tokenizer.specification)")
        }
        if let content {
            arguments.append("content = \(text: content)")
        }
        if let contentRowID {
            arguments.append("content_rowid = \(text: contentRowID)")
        }

        var query: ISO_9075.Fragment = "CREATE VIRTUAL TABLE "
        if ifNotExists {
            query.append("IF NOT EXISTS ")
        }
        if let schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: tableName) USING fts5(")
        query.append(arguments.joined(separator: ", "))
        query.append(")")
        return SQLQueryExpression(query)
    }
}

extension TableDefinition where QueryValue: _FTS5Table {
    /// The implicit SQLite rowid column for this FTS5 table.
    public var rowid: some QueryExpression<Int> {
        SQLQueryExpression("\(QueryValue.self).\(quote: "rowid")")
    }

    /// A predicate matching all indexed columns against an FTS5 query.
    ///
    /// The pattern is bound as a query value. It must use valid FTS5 query syntax.
    public func match(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        SQLQueryExpression("(\(QueryValue.self) MATCH \(bind: "\(pattern)"))")
    }
}

extension TableColumnExpression
where
    Root: _FTS5Table,
    Value.QueryOutput: _OptionalPromotable,
    Value.QueryOutput._Optionalized.Wrapped: StringProtocol
{
    /// A predicate matching this column against an FTS5 query.
    ///
    /// The column scope is encoded into the bound FTS5 pattern, so identifiers are never appended
    /// as raw SQL.
    public func match(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        Root.columns.match("\(name):\(ISO_9075.Identifier("\(pattern)").delimited)")
    }
}
