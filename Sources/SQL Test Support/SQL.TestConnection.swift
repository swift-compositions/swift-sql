internal import SQL

extension SQL {

    struct TestConnection: SQL.Connection {
        let database: SQL.TestDatabase
    }
}

extension SQL.TestConnection {
    func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int {
        await database.record(statement.sql, statement.bindings)
        return 0
    }

    func fetchAll<Value: Sendable>(
        _ statement: some SQL.Statement,
        decode: (any SQL.Row) throws(SQL.Error) -> Value
    ) async throws(SQL.Error) -> [Value] {
        await database.record(statement.sql, statement.bindings)
        let rows = await database.nextResultSet()
        var results: [Value] = []
        results.reserveCapacity(rows.count)
        for columns in rows {
            results.append(try decode(SQL.TestRow(columns)))
        }
        return results
    }

    func fetchOne<Value: Sendable>(
        _ statement: some SQL.Statement,
        decode: (any SQL.Row) throws(SQL.Error) -> Value
    ) async throws(SQL.Error) -> Value? {
        await database.record(statement.sql, statement.bindings)
        let rows = await database.nextResultSet()
        guard let first = rows.first else { return nil }
        return try decode(SQL.TestRow(first))
    }
}
