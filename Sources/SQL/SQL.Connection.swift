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

// `any SQL.Connection` / `any SQL.Row` / `any SQL.Database` existentials are the
// deliberate engine-free membrane design: conformers are engine-specific and
// heterogeneous; generics would leak the engine type into consumer signatures.
// swiftlint:disable no_any_protocol_existential
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

        /// Opens a pull-driven cursor and decodes at most one row for each iterator advance.
        ///
        /// The returned cursor is bound to this connection. Its provider must retain the lease until
        /// the cursor terminates, and map driver failures into ``SQL/Error``.
        func fetchCursor<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: @escaping @Sendable (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> SQL.Cursor<Value>
    }
}
// swiftlint:enable no_any_protocol_existential
