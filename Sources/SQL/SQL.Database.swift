// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension SQL {
    /// A full database handle: a ``SQL/Reader`` that also opens write and rollback scopes.
    ///
    /// The read/write split is the whole point of the handle. `write` runs its body inside a
    /// write transaction — `BEGIN`, the body against a connection-scoped handle, then `COMMIT`
    /// on success or `ROLLBACK` on a thrown error. `withRollback` runs its body inside a
    /// transaction that *always* ends with `ROLLBACK`; it lives on the handle (rather than in a
    /// separate test module) because only the conformer owns the connection/transaction machinery
    /// needed to guarantee the scope is torn down — it is the affordance a test uses to observe a
    /// statement's effect without persisting it.
    public protocol Database: SQL.Reader {
        /// Runs `body` inside a write transaction: `BEGIN`, the body, then `COMMIT` on success or
        /// `ROLLBACK` on a thrown error.
        func write<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value

        /// Runs `body` inside a transaction that always ends with `ROLLBACK` — the test affordance
        /// for observing a statement's effect without persisting it.
        func withRollback<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value
    }
}

extension SQL.Database {
    /// Executes a statement in its own write transaction and returns the row count.
    ///
    /// Convenience forwarding through ``write(_:)`` for the direct `db.execute(statement)` call
    /// shape (e.g. a migration's `CREATE TABLE`).
    public func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int {
        try await write { (connection: any SQL.Connection) throws(SQL.Error) -> Int in
            try await connection.execute(statement)
        }
    }

    /// Executes a query in its own write transaction and returns the row count.
    ///
    /// The concrete-`SQL.Query` overload backs the string-literal call shape `db.execute("…")`:
    /// a bare string literal cannot bind to the opaque `some SQL.Statement` parameter above, but
    /// it converts to ``SQL/Query`` via `ExpressibleByStringLiteral` and resolves here.
    public func execute(_ query: SQL.Query) async throws(SQL.Error) -> Int {
        try await write { (connection: any SQL.Connection) throws(SQL.Error) -> Int in
            try await connection.execute(query)
        }
    }
}
