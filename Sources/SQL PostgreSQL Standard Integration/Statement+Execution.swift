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

#if PostgreSQLStandardIntegration

    public import PostgreSQL_Standard
    public import SQL

    // `any SQL.Connection` / `any SQL.Row` / `any SQL.Database` existentials are the
    // deliberate engine-free membrane design: conformers are engine-specific and
    // heterogeneous; generics would leak the engine type into consumer signatures.
    // swiftlint:disable no_any_protocol_existential
    extension Statement {
        /// Lowers this DSL statement into a ``SQL/Query`` and runs it on `database` in a write scope.
        ///
        /// The statement-first execution sugar matching the app's `statement.execute(db)` call shape.
        ///
        /// - Note: This is the fire-and-forget verb (row count discarded). Row-decoding sugar —
        ///   `fetchAll` / `fetchOne` returning decoded `QueryOutput` values by driving the DSL
        ///   `QueryDecoder` over ``SQL/RowDecoder`` — lives in `Statement+Fetch.swift`, built on the
        ///   by-index `…IfPresent` accessors added to ``SQL/Row``.
        public func execute(_ database: any SQL.Database) async throws(SQL.Error) {
            let query = try SQL.Query(self)
            _ = try await database.execute(query)
        }
    }
// swiftlint:enable no_any_protocol_existential

#endif  // PostgreSQLStandardIntegration
