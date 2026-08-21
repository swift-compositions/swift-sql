public import SQL

extension SQL {

    public actor TestDatabase: SQL.Database {
        private var recorded: [Statement] = []
        private var scripts: [[[String: SQL.Value]]] = []
        private var enteredScopes: [Scope] = []

        public init() {}
    }
}

extension SQL.TestDatabase {

    public struct Statement: Sendable {
        public let sql: String
        public let bindings: [SQL.Value]
    }

    public enum Scope: Sendable, Equatable {
        case read
        case write
        case rollback
    }

    public var executed: [Statement] { recorded }

    public var scopes: [Scope] { enteredScopes }

    public func script(rows: [[String: SQL.Value]]) {
        scripts.append(rows)
    }

    func record(_ sql: String, _ bindings: [SQL.Value]) {
        recorded.append(Statement(sql: sql, bindings: bindings))
    }

    func nextResultSet() -> [[String: SQL.Value]] {
        scripts.isEmpty ? [] : scripts.removeFirst()
    }

    private func enter(_ scope: Scope) {
        enteredScopes.append(scope)
    }

    public func read<Value: Sendable>(
        _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
    ) async throws(SQL.Error) -> Value {
        enter(.read)
        return try await body(SQL.TestConnection(database: self))
    }

    public func write<Value: Sendable>(
        _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
    ) async throws(SQL.Error) -> Value {
        enter(.write)
        return try await body(SQL.TestConnection(database: self))
    }

    public func withRollback<Value: Sendable>(
        _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
    ) async throws(SQL.Error) -> Value {
        enter(.rollback)
        return try await body(SQL.TestConnection(database: self))
    }
}
