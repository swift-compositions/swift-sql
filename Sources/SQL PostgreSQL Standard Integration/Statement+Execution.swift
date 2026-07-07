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
    /// - Note: Only execute-style running is bridged. Row-decoding sugar (`fetchAll` / `fetchOne`
    ///   returning decoded records by driving the DSL `QueryDecoder`) is intentionally absent —
    ///   see the target-level report: the DSL decoder is a positional, mutating cursor requiring
    ///   `Optional`-per-column NULL detection and Foundation `UUID`/`Date`/`UInt64`/`Decimal`
    ///   columns, none of which ``SQL/Row``'s by-name/by-index accessor model exposes, so the
    ///   decoder cannot be driven over an `any SQL.Row` without new core surface.
    public func execute(_ database: any SQL.Database) async throws(SQL.Error) {
        let query = try SQL.Query(self)
        _ = try await database.execute(query)
    }
}
