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
    /// A connection-scoped execution handle: the verbs that run a ``SQL/Statement``.
    ///
    /// A connection is what a ``SQL/Reader/read(_:)`` or ``SQL/Database/write(_:)`` body receives.
    /// The query methods accept any ``SQL/Statement`` and never surface an engine type; decode
    /// closures receive an `any SQL.Row` consumed synchronously.
    public protocol Connection: Sendable {
        /// Executes a statement and returns the number of rows the server produced.
        func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int

        /// Executes a statement and decodes every row via the given closure.
        func fetchAll<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> [Value]

        /// Executes a statement and decodes the first row, or returns `nil` when there is none.
        func fetchOne<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value?
    }
}
