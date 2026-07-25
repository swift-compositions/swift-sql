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

internal import Byte_Primitives
internal import RFC_4122
internal import SQL
internal import Structured_Queries_Primitives
internal import Time_Primitive

extension SQL {
    // Signatures forced by external protocol Structured_Queries_Primitives.QueryDecoder
    // (untyped throws); `any SQL.Row` is the deliberate engine-free row abstraction.
    // swiftlint:disable typed_throws_required no_any_protocol_existential
    /// A positional `Structured Queries Primitives` `QueryDecoder` driven over an `any SQL.Row`.
    ///
    /// The DSL decodes a result row column-by-column through a mutating cursor: each `decode`
    /// reads the current column, then advances `index`. `nil` signals a `NULL` column (the DSL's
    /// `Optional` machinery turns a required-column `nil` into `missingRequiredColumn`); a type
    /// mismatch surfaces as ``SQL/Error/decoding(_:)`` from the underlying by-index `…IfPresent`
    /// accessor. Every requirement is now stated in institute vocabulary — `Instant` for a
    /// timestamp column, `QueryBinding.UUID` for an identifier, `[Byte]` for `blob`/`jsonb` — so a
    /// timestamp is handed straight through and an identifier only changes byte container.
    /// `UInt64` is the bit-pattern of the signed 64-bit column.
    ///
    /// The type is deliberately `internal`: it is an implementation detail of the fetch sugar, so
    /// the witness signatures the external `QueryDecoder` protocol forces never leak onto this
    /// target's public surface. The conformance methods are untyped-`throws` because the external
    /// `QueryDecoder` protocol requirements are untyped `throws` — the constraint is imposed by the
    /// DSL, not chosen here; every error actually thrown is a ``SQL/Error``.
    struct RowDecoder: QueryDecoder {
        let row: any SQL.Row
        var index: Int = 0

        init(row: any SQL.Row) {
            self.row = row
        }
    }
    // swiftlint:enable typed_throws_required no_any_protocol_existential
}

// swiftlint:disable typed_throws_required no_any_protocol_existential
extension SQL.RowDecoder {
    mutating func decode(_ columnType: [Byte].Type) throws -> [Byte]? {
        defer { index += 1 }
        return try row.bytesIfPresent(at: index)?.map { Byte($0) }
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

    mutating func decode(_ columnType: Instant.Type) throws -> Instant? {
        defer { index += 1 }
        return try row.timestampIfPresent(at: index)
    }

    mutating func decode(_ columnType: QueryBinding.UUID.Type) throws -> QueryBinding.UUID? {
        defer { index += 1 }
        guard let uuid = try row.uuidIfPresent(at: index) else { return nil }
        return QueryBinding.UUID(bytes: uuid.byteArray.map { Byte($0) })
    }
}
// swiftlint:enable typed_throws_required no_any_protocol_existential
