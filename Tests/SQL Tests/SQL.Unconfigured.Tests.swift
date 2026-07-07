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
import SQL_Dependencies_Integration
import Testing

@Test func unconfiguredReadThrowsConnection() async {
    let database = SQL.Unconfigured()
    await #expect(throws: SQL.Error.self) {
        _ = try await database.read { _ in 0 }
    }
}

@Test func unconfiguredExecuteThrowsConnection() async {
    let database: any SQL.Database = SQL.Unconfigured()
    do {
        _ = try await database.execute("SELECT 1")
        Issue.record("expected a thrown error")
    } catch {
        guard case .connection = error else {
            Issue.record("expected .connection, got \(error)")
            return
        }
    }
}
