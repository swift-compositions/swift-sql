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

import SQL
import Testing

@Test func `query carries SQL and bindings`() {
    let query = SQL.Query(
        sql: "SELECT * FROM t WHERE id = $1 AND name = $2",
        bindings: [.int(7), .text("repotraffic")]
    )
    #expect(query.sql.contains("$1"))
    #expect(query.bindings.count == 2)
    #expect(query.bindings.last == .text("repotraffic"))
}

@Test func `string literal query has no bindings`() {
    let query: SQL.Query = "CREATE TABLE accounts (id UUID PRIMARY KEY)"
    #expect(query.sql == "CREATE TABLE accounts (id UUID PRIMARY KEY)")
    #expect(query.bindings.isEmpty)
}
