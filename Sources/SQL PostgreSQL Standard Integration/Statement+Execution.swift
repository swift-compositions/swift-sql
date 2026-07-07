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
public import PostgreSQL_Standard

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
