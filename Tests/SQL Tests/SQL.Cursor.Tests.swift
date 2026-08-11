// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import SQL
import SQL_Test_Support
import Testing

@Test func `cursor pulls rows one at a time and releases on exhaustion`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["id": .int64(1)], ["id": .int64(2)]])

    let values = try await database.read { (connection: any SQL.Connection) throws(SQL.Error) -> [Int64] in
        let cursor = try await connection.fetchCursor(SQL.Query(sql: "SELECT id FROM users")) { row throws(SQL.Error) in
            try row.int64("id")
        }
        var iterator = cursor.makeAsyncIterator()

        let first = try #require(try await iterator.next())
        #expect(first == 1)
        let openCursorReleases = await database.closedCursors
        #expect(openCursorReleases == 0)

        let second = try #require(try await iterator.next())
        #expect(second == 2)
        let terminal = try await iterator.next()
        #expect(terminal == nil)
        return [first, second]
    }

    #expect(values == [1, 2])
    let closedCursorReleases = await database.closedCursors
    #expect(closedCursorReleases == 1)
}

@Test func `cursor close ends a shared stream exactly once`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["id": .int64(1)]])

    try await database.read { (connection: any SQL.Connection) throws(SQL.Error) in
        let cursor = try await connection.fetchCursor(SQL.Query(sql: "SELECT id FROM users")) { row throws(SQL.Error) in
            try row.int64("id")
        }
        var iterator = cursor.makeAsyncIterator()
        await cursor.close()
        await cursor.close()
        let terminal = try await iterator.next()
        #expect(terminal == nil)
    }

    let closedCursorReleases = await database.closedCursors
    #expect(closedCursorReleases == 1)
}
