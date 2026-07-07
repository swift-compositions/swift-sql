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
    /// The scripted ``SQL/Connection`` a ``SQL/TestDatabase`` hands to a scope body. Every verb
    /// records its statement on the owning database; `fetchAll` / `fetchOne` decode the database's
    /// next scripted result set through ``SQL/TestRow``.
    struct TestConnection: SQL.Connection {
        let database: SQL.TestDatabase

        func execute(_ statement: some SQL.Statement) async throws(SQL.Error) -> Int {
            await database.record(statement.sql, statement.bindings)
            return 0
        }

        func fetchAll<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> [Value] {
            await database.record(statement.sql, statement.bindings)
            let rows = await database.nextResultSet()
            var results: [Value] = []
            results.reserveCapacity(rows.count)
            for columns in rows {
                results.append(try decode(SQL.TestRow(columns)))
            }
            return results
        }

        func fetchOne<Value: Sendable>(
            _ statement: some SQL.Statement,
            decode: (any SQL.Row) throws(SQL.Error) -> Value
        ) async throws(SQL.Error) -> Value? {
            await database.record(statement.sql, statement.bindings)
            let rows = await database.nextResultSet()
            guard let first = rows.first else { return nil }
            return try decode(SQL.TestRow(first))
        }
    }
}
