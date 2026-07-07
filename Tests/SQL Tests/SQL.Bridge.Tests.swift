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

import Foundation
import PostgreSQL_Standard
import RFC_4122
import SQL
import SQL_PostgreSQL_Standard_Integration
import SQL_Test_Support
import Testing
import Time_Primitive

@Test func bridgeLowersSQLTextAndPositionalBindings() throws {
    let fragment: QueryFragment =
        "SELECT * FROM t WHERE id = \(QueryBinding.int(7)) AND name = \(QueryBinding.text("repotraffic"))"
    let query = try SQL.Query(SQLQueryExpression<()>(fragment))
    #expect(query.sql.contains("$1"))
    #expect(query.sql.contains("$2"))
    #expect(query.bindings == [.int64(7), .text("repotraffic")])
}

@Test func bridgeMapsUUIDBinding() throws {
    let uuid = UUID()
    let fragment: QueryFragment = "SELECT \(QueryBinding.uuid(uuid))"
    let query = try SQL.Query(SQLQueryExpression<()>(fragment))
    #expect(query.bindings == [.uuid(RFC_4122.UUID(bytes: uuid.uuid))])
}

@Test func bridgeMapsDateBindingToInstant() throws {
    let date = Date(timeIntervalSince1970: 1_700_000_000)
    let fragment: QueryFragment = "SELECT \(QueryBinding.date(date))"
    let query = try SQL.Query(SQLQueryExpression<()>(fragment))
    guard case .timestamp(let instant) = query.bindings.first else {
        Issue.record("expected a timestamp binding, got \(query.bindings)")
        return
    }
    #expect(instant.secondsSinceUnixEpoch == 1_700_000_000)
    #expect(instant.nanosecondFraction == 0)
}

@Test func bridgeMapsJSONBBinding() throws {
    let fragment: QueryFragment = "SELECT \(QueryBinding.jsonb(Data([0x7b, 0x7d])))"
    let query = try SQL.Query(SQLQueryExpression<()>(fragment))
    #expect(query.bindings == [.jsonb([0x7b, 0x7d])])
}

@Test func bridgeThrowsBindingForUnsupportedCase() {
    let fragment: QueryFragment = "SELECT \(QueryBinding.decimal(Decimal(1)))"
    #expect(throws: SQL.Error.self) {
        _ = try SQL.Query(SQLQueryExpression<()>(fragment))
    }
}

@Test func statementExecuteSugarRunsOnDatabase() async throws {
    let database = SQL.TestDatabase()
    let fragment: QueryFragment = "INSERT INTO t (id) VALUES (\(QueryBinding.int(5)))"
    try await SQLQueryExpression<()>(fragment).execute(database)
    let executed = await database.executed
    #expect(executed.count == 1)
    #expect(executed[0].sql.contains("$1"))
    #expect(executed[0].bindings == [.int64(5)])
}
