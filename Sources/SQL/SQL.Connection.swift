extension SQL {

    public protocol Connection: Sendable {

        func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int

        func fetchAll<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> [Value]

        func fetchOne<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value?
    }
}
