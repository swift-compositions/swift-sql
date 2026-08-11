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

@Suite
struct `Cursor Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Cursor Tests`.Unit {
    @Test
    func `next returns one element with the only continuation and reuses on exhaustion`() async throws {
        let database = SQL.TestDatabase()
        await database.script(rows: [["id": .int64(1)], ["id": .int64(2)]])

        let values = try await database.read { (connection: any SQL.Connection) throws(SQL.Error) -> [Int64] in
            let cursor = try await connection.fetchCursor(
                SQL.Query(sql: "SELECT id FROM users")
            ) { row throws(SQL.Error) in
                try row.int64("id")
            }

            let firstAdvance = await cursor.next()
            switch consume firstAdvance {
            case .element(let first, let cursor):
                #expect(first == 1)
                let openCursorReleases = await database.closedCursors
                #expect(openCursorReleases == 0)

                let secondAdvance = await cursor.next()
                switch consume secondAdvance {
                case .element(let second, let cursor):
                    #expect(second == 2)
                    let terminalAdvance = await cursor.next()
                    switch consume terminalAdvance {
                    case .exhausted:
                        return [first, second]
                    case .element:
                        throw SQL.Error.execution("cursor produced an unexpected third row")
                    case .failure(let error):
                        throw error
                    }

                case .exhausted:
                    throw SQL.Error.execution("cursor exhausted before its second row")
                case .failure(let error):
                    throw error
                }

            case .exhausted:
                throw SQL.Error.execution("cursor exhausted before its first row")
            case .failure(let error):
                throw error
            }
        }

        #expect(values == [1, 2])
        let closedCursorReleases = await database.closedCursors
        #expect(closedCursorReleases == 1)
    }

    @Test
    func `successful close resolves the live cursor`() async throws {
        let database = SQL.TestDatabase()
        await database.script(rows: [["id": .int64(1)]])

        try await database.read { (connection: any SQL.Connection) throws(SQL.Error) in
            let cursor = try await connection.fetchCursor(
                SQL.Query(sql: "SELECT id FROM users")
            ) { row throws(SQL.Error) in
                try row.int64("id")
            }
            switch await cursor.close() {
            case .success:
                return
            case .failure(let error):
                throw error
            }
        }

        let closedCursorReleases = await database.closedCursors
        #expect(closedCursorReleases == 1)
    }
}
