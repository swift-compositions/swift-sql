public import ISO_9075_Foundation

extension ISO_9075.Fragment.StringInterpolation {
    public mutating func appendInterpolation<QueryValue: QueryBindable>(
        _ queryOutput: QueryValue.QueryOutput,
        as representableType: QueryValue.Type
    ) {
        appendInterpolation(QueryValue(queryOutput: queryOutput))
    }

    public mutating func appendInterpolation(bind expression: some QueryExpression) {
        appendInterpolation(expression.queryFragment)
    }

    public mutating func appendInterpolation(_ expression: some QueryExpression) {
        appendInterpolation(expression.queryFragment)
    }

    public mutating func appendInterpolation(_ statement: some PartialSelectStatement) {
        appendInterpolation(statement.query)
    }

    public mutating func appendInterpolation<T: Table>(_ table: T.Type) {
        if let schemaName = table.schemaName {
            appendInterpolation(quote: schemaName)
            appendLiteral(".")
        }
        appendInterpolation(ISO_9075.Identifier(table.tableAlias ?? table.tableName, key: ObjectIdentifier(T.self)))
    }
}
