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
    /// The unconfigured default ``SQL/Database`` — every verb throws
    /// ``SQL/Error/connection(_:)`` telling the caller to wire a live database at boot.
    ///
    /// It is the `liveValue`/`testValue` of the `defaultDatabase` dependency, so a graph that
    /// forgets to inject a real handle fails loudly at first use rather than silently no-op'ing.
    public struct Unconfigured: SQL.Database {
        public init() {}

        private static var unconfigured: SQL.Error {
            .connection("defaultDatabase is not configured — wire a live SQL.Database at boot")
        }

        public func read<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            throw Self.unconfigured
        }

        public func write<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            throw Self.unconfigured
        }

        public func withRollback<Value: Sendable>(
            _ body: @Sendable (any SQL.Connection) async throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value {
            throw Self.unconfigured
        }
    }
}
// swiftlint:enable no_any_protocol_existential
