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

        public init() {}

        /// A recorded statement: the SQL text and the bindings it ran with.
        public struct Statement: Sendable {
            public let sql: String
            public let bindings: [SQL.Value]
        }

        /// The statements run so far, in execution order.
        public var executed: [Statement] { recorded }

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

        public func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            try await body(SQL.TestConnection(database: self))
        }

        public func write<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            try await body(SQL.TestConnection(database: self))
        }

        public func withRollback<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            try await body(SQL.TestConnection(database: self))
        }
    }
}
