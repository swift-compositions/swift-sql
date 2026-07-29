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

#if PostgreSQLStandardIntegration

    import Byte_Primitives
    import PostgreSQL_Standard
    import RFC_4122
    import SQL
    import SQL_PostgreSQL_Standard_Integration
    import SQL_Test_Support
    import Testing
    import Time_Primitive

    @Test func `bridge lowers SQL text and positional bindings`() throws {
        let fragment: QueryFragment =
            "SELECT * FROM t WHERE id = \(QueryBinding.int(7)) AND name = \(QueryBinding.text("repotraffic"))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.sql.contains("$1"))
        #expect(query.sql.contains("$2"))
        #expect(query.bindings == [.int64(7), .text("repotraffic")])
    }

    @Test func `bridge maps UUID binding`() throws {
        let raw: [UInt8] = [
            0x55, 0x0e, 0x84, 0x00, 0xe2, 0x9b, 0x41, 0xd4,
            0xa7, 0x16, 0x44, 0x66, 0x55, 0x44, 0x00, 0x00,
        ]
        let binding = QueryBinding.UUID(bytes: raw.map { Byte($0) })
        let fragment: QueryFragment = "SELECT \(QueryBinding.uuid(binding))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.uuid(try RFC_4122.UUID(raw))])
    }

    @Test func `bridge throws binding for a UUID of the wrong width`() {
        let binding = QueryBinding.UUID(bytes: [Byte(0x01), Byte(0x02)])
        let fragment: QueryFragment = "SELECT \(QueryBinding.uuid(binding))"
        #expect(throws: SQL.Error.self) {
            _ = try SQL.Query(SQLQueryExpression<()>(fragment))
        }
    }

    @Test func `bridge maps date binding to instant`() throws {
        let instant = try Instant(secondsSinceUnixEpoch: 1_700_000_000, nanosecondFraction: 500_000_000)
        let fragment: QueryFragment = "SELECT \(QueryBinding.date(instant))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        // The binding already carries an `Instant`, so the bridge hands it through unchanged — no
        // epoch arithmetic, and no sub-second precision lost on the way across.
        #expect(query.bindings == [.timestamp(instant)])
    }

    @Test func `bridge maps JSONB binding`() throws {
        let fragment: QueryFragment = "SELECT \(QueryBinding.jsonb([Byte(0x7b), Byte(0x7d)]))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.jsonb([0x7b, 0x7d])])
    }

    @Test func `bridge maps blob binding`() throws {
        let fragment: QueryFragment = "SELECT \(QueryBinding.blob([Byte(0xde), Byte(0xad)]))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.blob([0xde, 0xad])])
    }

    @Test func `bridge carries a decimal as its exact digit string`() throws {
        // Deliberately wider than any fixed-width decimal type accepts: `numeric` admits it, so
        // the seam must carry the digits verbatim rather than parse and narrow them.
        let digits = "123456789012345678901234567890123456789.000000000000000000001"
        let fragment: QueryFragment = "SELECT \(QueryBinding.decimal(digits))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.decimal(digits)])
    }

    @Test func `bridge maps every element-typed array onto the recursive array case`() throws {
        let raw: [UInt8] = [
            0x55, 0x0e, 0x84, 0x00, 0xe2, 0x9b, 0x41, 0xd4,
            0xa7, 0x16, 0x44, 0x66, 0x55, 0x44, 0x00, 0x00,
        ]
        let uuid = try RFC_4122.UUID(raw)
        let binding = QueryBinding.UUID(bytes: raw.map { Byte($0) })

        let cases: [(QueryBinding, SQL.Value)] = [
            (.boolArray([true, false]), .array([.bool(true), .bool(false)])),
            (.stringArray(["a", "b"]), .array([.text("a"), .text("b")])),
            (.intArray([1, 2]), .array([.int(1), .int(2)])),
            (.int16Array([1, 2]), .array([.int64(1), .int64(2)])),
            (.int32Array([1, 2]), .array([.int64(1), .int64(2)])),
            (.int64Array([1, 2]), .array([.int64(1), .int64(2)])),
            (.doubleArray([1.5]), .array([.double(1.5)])),
            (.uuidArray([binding]), .array([.uuid(uuid)])),
        ]

        for (binding, expected) in cases {
            let fragment: QueryFragment = "SELECT \(binding)"
            let query = try SQL.Query(SQLQueryExpression<()>(fragment))
            #expect(query.bindings == [expected])
        }
    }

    @Test func `bridge maps a generic array elementwise rather than degrading it to null`() throws {
        // The postgres-nio path binds NULL here, discarding caller data. The recursive case gives
        // this binding the same fidelity as the typed arrays.
        let fragment: QueryFragment = "SELECT \(QueryBinding.genericArray([.int(1), .text("a"), .null]))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.array([.int64(1), .text("a"), .null])])
    }

    @Test func `bridge maps a nested array`() throws {
        let fragment: QueryFragment = "SELECT \(QueryBinding.genericArray([.intArray([1, 2])]))"
        let query = try SQL.Query(SQLQueryExpression<()>(fragment))
        #expect(query.bindings == [.array([.array([.int(1), .int(2)])])])
    }

    private struct BindingProbeError: Swift.Error {}

    @Test func `bridge throws binding for an invalid binding`() {
        let binding = QueryBinding.invalid(QueryBindingError(underlyingError: BindingProbeError()))
        let fragment: QueryFragment = "SELECT \(binding)"
        #expect(throws: SQL.Error.self) {
            _ = try SQL.Query(SQLQueryExpression<()>(fragment))
        }
    }

    @Test func `statement execute sugar runs on database`() async throws {
        let database = SQL.TestDatabase()
        let fragment: QueryFragment = "INSERT INTO t (id) VALUES (\(QueryBinding.int(5)))"
        try await SQLQueryExpression<()>(fragment).execute(database)
        let executed = await database.executed
        #expect(executed.count == 1)
        #expect(executed[0].sql.contains("$1"))
        #expect(executed[0].bindings == [.int64(5)])
    }

#endif  // PostgreSQLStandardIntegration
