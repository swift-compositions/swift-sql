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
    /// A read-scoped database handle: runs a body against a leased ``SQL/Connection``.
    ///
    /// `read` establishes a connection scope (a leased pool connection, or a read transaction,
    /// as the conformer sees fit) and runs `body` against it. The narrower half of the
    /// read/write split — see ``SQL/Database`` for the write and rollback scopes.
    public protocol Reader: Sendable {
        /// Runs `body` against a connection in a read scope, returning its result.
        func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value
    }
}
// swiftlint:enable no_any_protocol_existential
