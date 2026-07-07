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

internal import Foundation
internal import RFC_4122
internal import SQL
internal import Structured_Queries_Primitives
internal import Time_Primitive

extension SQL {
    /// A positional `Structured Queries Primitives` `QueryDecoder` driven over an `any SQL.Row`.
    ///
    /// The DSL decodes a result row column-by-column through a mutating cursor: each `decode`
    /// reads the current column, then advances `index`. `nil` signals a `NULL` column (the DSL's
    /// `Optional` machinery turns a required-column `nil` into `missingRequiredColumn`); a type
    /// mismatch surfaces as ``SQL/Error/decoding(_:)`` from the underlying by-index `…IfPresent`
    /// accessor. Foundation `Date`/`UUID` are reconstituted from institute vocabulary (`Instant`,
    /// ``RFC_4122/UUID``); `UInt64` is the bit-pattern of the signed 64-bit column; `Decimal` is an
    /// unsupported v0 seam.
    ///
    /// The type is deliberately `internal`: it is an implementation detail of the fetch sugar, so
    /// the Foundation types the external `QueryDecoder` protocol forces into these witness
    /// signatures never leak onto this target's public surface (the membrane keeps Foundation an
    /// `internal import`). The conformance methods are untyped-`throws` because the external
    /// `QueryDecoder` protocol requirements are untyped `throws` — the constraint is imposed by the
    /// DSL, not chosen here; every error actually thrown is a ``SQL/Error``.
    struct RowDecoder: QueryDecoder {
        let row: any SQL.Row
        var index: Int = 0

        init(row: any SQL.Row) {
            self.row = row
        }

        mutating func decode(_ columnType: [UInt8].Type) throws -> [UInt8]? {
            defer { index += 1 }
            return try row.bytesIfPresent(at: index)
        }

        mutating func decode(_ columnType: Double.Type) throws -> Double? {
            defer { index += 1 }
            return try row.doubleIfPresent(at: index)
        }

        mutating func decode(_ columnType: Int64.Type) throws -> Int64? {
            defer { index += 1 }
            return try row.int64IfPresent(at: index)
        }

        mutating func decode(_ columnType: UInt64.Type) throws -> UInt64? {
            defer { index += 1 }
            return try row.int64IfPresent(at: index).map { UInt64(bitPattern: $0) }
        }

        mutating func decode(_ columnType: String.Type) throws -> String? {
            defer { index += 1 }
            return try row.stringIfPresent(at: index)
        }

        mutating func decode(_ columnType: Bool.Type) throws -> Bool? {
            defer { index += 1 }
            return try row.boolIfPresent(at: index)
        }

        mutating func decode(_ columnType: Int.Type) throws -> Int? {
            defer { index += 1 }
            return try row.intIfPresent(at: index)
        }

        mutating func decode(_ columnType: Date.Type) throws -> Date? {
            defer { index += 1 }
            guard let instant = try row.timestampIfPresent(at: index) else { return nil }
            return Date(
                timeIntervalSince1970: Double(instant.secondsSinceUnixEpoch)
                    + Double(instant.nanosecondFraction) / 1_000_000_000
            )
        }

        mutating func decode(_ columnType: UUID.Type) throws -> UUID? {
            defer { index += 1 }
            guard let uuid = try row.uuidIfPresent(at: index) else { return nil }
            return Foundation.UUID(uuid: uuid.bytes)
        }

        mutating func decode(_ columnType: Decimal.Type) throws -> Decimal? {
            defer { index += 1 }
            throw SQL.Error.decoding("decimal unsupported by the v0 seam")
        }
    }
}
