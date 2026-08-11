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

public import SQL

// `any SQL.Connection` / `any SQL.Row` / `any SQL.Database` existentials are the
// deliberate engine-free membrane design: conformers are engine-specific and
// heterogeneous; generics would leak the engine type into consumer signatures.
// swiftlint:disable no_any_protocol_existential
extension SQL {
    /// An engine-free, scripted ``SQL/Database`` for testing consumers without a live engine.
    ///
    /// It records every statement its connection runs (``executed``) and answers `fetchAll` /
    /// `fetchOne` from a FIFO queue of scripted result sets enqueued via ``script(rows:)``. With
    /// no script enqueued the defaults hold: `fetchAll` returns `[]`, `fetchOne` returns `nil`,
    /// and `execute` returns `0`. `read` / `write` / `withRollback` all run their body against an
    /// internal scripted ``SQL/Connection`` — there is no transactional persistence to model, so
    /// the three scopes differ only in intent.
    public actor TestDatabase: SQL.Database {
        private var recorded: [Statement] = []
        private var scripts: [[[String: SQL.Value]]] = []
        nonisolated let cursorStorage = SQL.TestDatabase.Cursor.Storage()
        private var enteredScopes: [Scope] = []

        public init() {}
    }
}

extension SQL.TestDatabase {
    /// A recorded statement: the SQL text and the bindings it ran with.
    public struct Statement: Sendable {
        public let sql: String
        public let bindings: [SQL.Value]
    }

    /// A connection scope a body ran in, recorded so a test can assert routing — for example that the
    /// statement-fetch sugar takes the write-capable scope (so an `INSERT … RETURNING` fetch is
    /// never run inside a read scope).
    public enum Scope: Sendable, Equatable {
        case read
        case write
        case rollback
    }

    /// The statements run so far, in execution order.
    public var executed: [Statement] { recorded }

    /// The connection scopes entered so far, in entry order.
    public var scopes: [Scope] { enteredScopes }

    /// The number of provider cursor releases observed so far.
    public var closedCursors: Int { cursorStorage.closed }

    /// Enqueues one scripted result set (an ordered list of rows) for the next `fetchAll` /
    /// `fetchOne` to consume.
    public func script(rows: [[String: SQL.Value]]) {
        scripts.append(rows)
    }

    func record(_ sql: String, _ bindings: [SQL.Value]) {
        recorded.append(Statement(sql: sql, bindings: bindings))
    }

    func nextResultSet() -> [[String: SQL.Value]] {
        scripts.isEmpty ? [] : scripts.removeFirst()
    }

    func openCursor() -> Int {
        cursorStorage.open(nextResultSet())
    }

    func nextCursorRow(_ identifier: Int) -> [String: SQL.Value]? {
        cursorStorage.next(identifier)
    }

    nonisolated func closeCursor(_ identifier: Int) {
        cursorStorage.close(identifier)
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
// swiftlint:enable no_any_protocol_existential
