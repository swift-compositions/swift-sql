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

@Test func `unconfigured read throws connection`() async {
    let database = SQL.Unconfigured()
    await #expect(throws: SQL.Error.self) {
        _ = try await database.read { _ in 0 }
    }
}

@Test func `unconfigured execute throws connection`() async {
    let database: any SQL.Database = SQL.Unconfigured()
    do throws(SQL.Error) {
        _ = try await database.execute("SELECT 1")
        Issue.record("expected a thrown error")
    } catch {
        guard case .connection = error else {
            Issue.record("expected .connection, got \(error)")
            return
        }
    }
}
