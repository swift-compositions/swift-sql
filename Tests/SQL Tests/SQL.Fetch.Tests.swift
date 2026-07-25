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

import Byte_Primitives
import PostgreSQL_Standard
// `@Table` is declared in the macro-declaration module upstream split out of `PostgreSQL
// Standard`; a macro attribute is not reachable through the runtime library's re-export, so the
// fixture below needs this import directly. Matches swift-postgresql-standard's own test files.
import PostgreSQL_Standard_Macros
import RFC_4122
import SQL
import SQL_Test_Support
import Testing
import Time_Primitive

// `@testable` reaches the internal `SQL.RowDecoder` — the positional cursor is an implementation
// detail of the fetch sugar (its `QueryDecoder` witnesses are kept off the public surface), so
// the decoder-direct tests below drive it under a testable import.
@testable import SQL_PostgreSQL_Standard_Integration

// MARK: - @Table fixture

@Table
struct FetchFixture {
    let id: Int
    var name: String
}

// MARK: - SQL.RowDecoder (positional cursor) tests

@Test func `decoder advances cursor across columns`() throws {
    // Sorted key order ["a", "b"] → index 0 = 10, index 1 = 20.
    let row = SQL.TestRow(["a": .int64(10), "b": .int64(20)])
    var decoder = SQL.RowDecoder(row: row)
    #expect(try decoder.decode(Int64.self) == 10)
    #expect(try decoder.decode(Int64.self) == 20)
}

@Test func `decoder returns nil for null column`() throws {
    let row = SQL.TestRow(["a": .null])
    var decoder = SQL.RowDecoder(row: row)
    #expect(try decoder.decode(Int64.self) == nil)
}

@Test func `decoder throws decoding on type mismatch`() {
    let row = SQL.TestRow(["a": .text("not a number")])
    var decoder = SQL.RowDecoder(row: row)
    #expect(throws: SQL.Error.self) {
        _ = try decoder.decode(Int64.self)
    }
}

@Test func `decoder bitcasts Int64 to UInt64`() throws {
    let row = SQL.TestRow(["a": .int64(-1)])
    var decoder = SQL.RowDecoder(row: row)
    #expect(try decoder.decode(UInt64.self) == UInt64.max)
}

@Test func `decoder returns the timestamp column as an instant`() throws {
    let instant = try Instant(secondsSinceUnixEpoch: 1_700_000_000, nanosecondFraction: 500_000_000)
    let row = SQL.TestRow(["a": .timestamp(instant)])
    var decoder = SQL.RowDecoder(row: row)
    // The requirement is stated in `Instant`, so the row's own timestamp is handed straight
    // through — no epoch round-trip, and the nanosecond fraction survives exactly.
    #expect(try decoder.decode(Instant.self) == instant)
}

@Test func `decoder converts RFC UUID to a query binding UUID`() throws {
    let raw: [UInt8] = [
        0x55, 0x0e, 0x84, 0x00, 0xe2, 0x9b, 0x41, 0xd4,
        0xa7, 0x16, 0x44, 0x66, 0x55, 0x44, 0x00, 0x00,
    ]
    let row = SQL.TestRow(["a": .uuid(try RFC_4122.UUID(raw))])
    var decoder = SQL.RowDecoder(row: row)
    let decoded = try #require(try decoder.decode(QueryBinding.UUID.self))
    #expect(decoded == QueryBinding.UUID(bytes: raw.map { Byte($0) }))
}

@Test func `decoder returns the blob column as bytes`() throws {
    let raw: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    let row = SQL.TestRow(["a": .blob(raw)])
    var decoder = SQL.RowDecoder(row: row)
    #expect(try decoder.decode([Byte].self) == raw.map { Byte($0) })
}

// MARK: - Fetch sugar over SQL.TestDatabase

@Test func `fetch all single value decodes column`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["id": .int64(1)], ["id": .int64(2)], ["id": .int64(3)]])
    let ids = try await FetchFixture.select { $0.id }.fetchAll(database)
    #expect(ids == [1, 2, 3])
}

@Test func `fetch all pack decodes tuple`() async throws {
    let database = SQL.TestDatabase()
    // Sorted keys ["id", "name"] match the select's column order (id, name).
    await database.script(rows: [
        ["id": .int64(1), "name": .text("alice")],
        ["id": .int64(2), "name": .text("bob")],
    ])
    let rows = try await FetchFixture.select { ($0.id, $0.name) }.fetchAll(database)
    #expect(rows.count == 2)
    #expect(rows[0].0 == 1)
    #expect(rows[0].1 == "alice")
    #expect(rows[1].0 == 2)
    #expect(rows[1].1 == "bob")
}

@Test func `fetch one returns nil on empty result set`() async throws {
    let database = SQL.TestDatabase()
    // No script enqueued → the scripted database yields an empty result set.
    let first = try await FetchFixture.select { $0.id }.fetchOne(database)
    #expect(first == nil)
}

@Test func `fetch all whole row decodes records`() async throws {
    let database = SQL.TestDatabase()
    // Sorted keys ["id", "name"] match the table's declared column order (id, name).
    await database.script(rows: [
        ["id": .int64(1), "name": .text("alice")],
        ["id": .int64(2), "name": .text("bob")],
    ])
    let records = try await FetchFixture.all.fetchAll(database)
    #expect(records.count == 2)
    #expect(records[0].id == 1)
    #expect(records[0].name == "alice")
    #expect(records[1].id == 2)
    #expect(records[1].name == "bob")
}

@Test func `fetch one whole row decodes first record`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["id": .int64(7), "name": .text("carol")]])
    let record = try #require(
        try await FetchFixture.where { $0.id == 7 }.fetchOne(database)
    )
    #expect(record.id == 7)
    #expect(record.name == "carol")
}

@Test func `fetch one whole row returns nil on empty result set`() async throws {
    let database = SQL.TestDatabase()
    let record = try await FetchFixture.all.fetchOne(database)
    #expect(record == nil)
}

@Test func `insert returning fetch takes write scope`() async throws {
    let database = SQL.TestDatabase()
    await database.script(rows: [["id": .int64(99)]])
    // INSERT … RETURNING is a fetch-with-effects: the sugar must run it in the write-capable scope,
    // never `read`.
    let id =
        try await FetchFixture
        .insert { FetchFixture.Draft(name: "carol") }
        .returning(\.id)
        .fetchOne(database)
    #expect(id == 99)
    let scopes = await database.scopes
    #expect(scopes == [.write])
}
