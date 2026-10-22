public import ISO_9075_Foundation

extension Schema {
    /// A typed `CREATE VIRTUAL TABLE ... USING fts5` statement.
    public struct Virtual<Root: Table>: Statement, Sendable {
        public typealias QueryValue = ()
        public typealias From = Never

        let ifNotExists: Bool
        let fields: [ISO_9075.Fragment]
        let options: [ISO_9075.Fragment]

        package init(
            ifNotExists: Bool,
            fields: [ISO_9075.Fragment],
            options: [ISO_9075.Fragment]
        ) {
            self.ifNotExists = ifNotExists
            self.fields = fields
            self.options = options
        }

        public var query: ISO_9075.Fragment {
            var query: ISO_9075.Fragment = "CREATE VIRTUAL TABLE"
            if ifNotExists {
                query.append(" IF NOT EXISTS")
            }
            query.append(" ")
            if let schemaName = Root.schemaName {
                query.append("\(quote: schemaName).")
            }
            query.append("\(quote: Root.tableName) USING fts5(")
            query.append("\(.newline)\((fields + options).joined(separator: ",\n").indented())")
            query.append("\(.newline))")
            return query
        }
    }
}

extension Schema.Create {
    /// Creates an FTS5 virtual table from typed fields of `Root`.
    public func fts5(
        ifNotExists: Bool = false,
        tokenizer: Schema.FTS5.Tokenizer? = nil,
        @Schema.FTS5.Builder fields: (Root.TableColumns) -> [ISO_9075.Fragment]
    ) -> Schema.Virtual<Root> {
        Schema.Virtual(
            ifNotExists: ifNotExists,
            fields: fields(Root.columns),
            options: tokenizer.map { ["tokenize = \(text: $0.text)"] } ?? []
        )
    }

    /// Creates an external-content FTS5 virtual table from typed table declarations.
    public func fts5<Content: Table>(
        ifNotExists: Bool = false,
        content: Content.Type,
        tokenizer: Schema.FTS5.Tokenizer? = nil,
        @Schema.FTS5.Builder fields: (Root.TableColumns) -> [ISO_9075.Fragment]
    ) -> Schema.Virtual<Root> {
        var options: [ISO_9075.Fragment] = ["content = \(text: Content.tableName)"]
        if let tokenizer {
            options.append("tokenize = \(text: tokenizer.text)")
        }
        return Schema.Virtual(
            ifNotExists: ifNotExists,
            fields: fields(Root.columns),
            options: options
        )
    }

    /// Creates an external-content FTS5 virtual table with a typed content row identifier.
    public func fts5<Content: Table, RowID: TableColumnExpression>(
        ifNotExists: Bool = false,
        content: Content.Type,
        rowid: KeyPath<Content.TableColumns, RowID>,
        tokenizer: Schema.FTS5.Tokenizer? = nil,
        @Schema.FTS5.Builder fields: (Root.TableColumns) -> [ISO_9075.Fragment]
    ) -> Schema.Virtual<Root> where RowID.Root == Content {
        let rowid = Content.columns[keyPath: rowid]
        var options: [ISO_9075.Fragment] = [
            "content = \(text: Content.tableName)",
            "content_rowid = \(text: rowid.name)",
        ]
        if let tokenizer {
            options.append("tokenize = \(text: tokenizer.text)")
        }
        return Schema.Virtual(
            ifNotExists: ifNotExists,
            fields: fields(Root.columns),
            options: options
        )
    }
}
