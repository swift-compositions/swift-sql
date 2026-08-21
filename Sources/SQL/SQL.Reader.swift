extension SQL {

    public protocol Reader: Sendable {

        func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value
    }
}
