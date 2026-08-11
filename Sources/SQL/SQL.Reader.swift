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
    /// A database reading interface: scopes a leased ``SQL/Connection`` or transfers one into a
    /// cursor.
    ///
    /// `read` establishes a connection scope (a leased pool connection, or a read transaction,
    /// as the conformer sees fit) and runs `body` against it. `cursor(_:decode:)` instead transfers
    /// unique ownership of that lease to the caller. This is the narrower half of the read/write
    /// split — see ``SQL/Database`` for the write and rollback scopes.
    public protocol Reader: Sendable {
        /// Opens a cursor whose uniquely owned provider context transfers into the caller.
        ///
        /// The reader, rather than a scoped SQL connection, owns this operation because only the
        /// database implementation can consume a checked-out lease into the returned cursor.
        func cursor<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: sending @escaping (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> sending SQL.Cursor<Value>

        /// Runs `body` against a connection in a read scope, returning its result.
        func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value
    }
}
// swiftlint:enable no_any_protocol_existential
