extension SQL {

    public protocol Database: SQL.Reader {

        func write<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value

        func withRollback<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value
    }
}

extension SQL.Database {

    public func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int {
        try await write { (connection: any SQL.Connection) throws(SQL.Error) -> Int in
            try await connection.execute(statement)
        }
    }

    public func execute(_ query: SQL.Query) async throws(SQL.Error) -> Int {
        try await write { (connection: any SQL.Connection) throws(SQL.Error) -> Int in
            try await connection.execute(query)
        }
    }
}
